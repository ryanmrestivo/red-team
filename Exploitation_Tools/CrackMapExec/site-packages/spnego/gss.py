# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type  # noqa (fixes E402 for the imports below)

import base64
import contextlib
import logging
import os
import sys
import tempfile

from spnego._compat import (
    Generator,
    List,
    Optional,
    Tuple,
    reraise,
)

from spnego._context import (
    ContextProxy,
    ContextReq,
    GSSMech,
    IOVWrapResult,
    IOVUnwrapResult,
    UnwrapResult,
    WinRMWrapResult,
    WrapResult,
    wrap_system_error,
)

from spnego._text import (
    text_type,
    to_bytes,
    to_text,
)

from spnego.exceptions import (
    GSSError as NativeError,
    NegotiateOptions,
    SpnegoError,
)

from spnego.iov import (
    BufferType,
    IOVBuffer,
)


log = logging.getLogger(__name__)

HAS_GSSAPI = True
GSSAPI_IMP_ERR = None
try:
    import gssapi

    from gssapi.raw import (
        acquire_cred_with_password,
        ChannelBindings,
        exceptions as gss_errors,
        GSSError,
        inquire_sec_context_by_oid,
        set_sec_context_option,
    )
except ImportError:
    GSSAPI_IMP_ERR = sys.exc_info()
    HAS_GSSAPI = False
    log.debug("Python gssapi not available, cannot use any GSSAPIProxy protocols: %s" % str(GSSAPI_IMP_ERR[1]))


HAS_IOV = True
GSSAPI_IOV_IMP_ERR = None
try:
    from gssapi.raw import (
        IOV,
        IOVBufferType,
        unwrap_iov,
        wrap_iov,
    )
except ImportError as err:
    GSSAPI_IOV_IMP_ERR = sys.exc_info()
    HAS_IOV = False
    log.debug("Python gssapi IOV extension not available: %s" % str(GSSAPI_IOV_IMP_ERR[1]))

_GSS_C_INQ_SSPI_SESSION_KEY = "1.2.840.113554.1.2.2.5.5"

# https://github.com/simo5/gss-ntlmssp/blob/bfc7232dbb2259072a976fc9cdb6ae4bfd323304/src/gssapi_ntlmssp.h#L68
_GSS_NTLMSSP_RESET_CRYPTO_OID = '1.3.6.1.4.1.7165.655.1.3'

# https://github.com/krb5/krb5/blob/master/src/lib/gssapi/spnego/spnego_mech.c#L483
_GSS_SPNEGO_REQUIRE_MIC_OID_STRING = '1.3.6.1.4.1.7165.655.1.2'


def _available_protocols(options=None):  # type: (Optional[NegotiateOptions]) -> List[str, ...]
    """ Return a list of protocols that GSSAPIProxy can offer. """
    if not options:
        options = NegotiateOptions(0)

    protocols = []
    if HAS_GSSAPI:
        # We can't offer Kerberos if the caller requires WinRM wrapping and IOV isn't available.
        if not (options & NegotiateOptions.wrapping_winrm and not HAS_IOV):
            protocols = ['kerberos']

        # We can only offer NTLM if the mech is installed and can retrieve the functionality the caller desires.
        if _gss_ntlmssp_available(session_key=bool(options & NegotiateOptions.session_key)):
            protocols.append('ntlm')

        # We can only offer Negotiate if we can offer both Kerberos and NTLM.
        if len(protocols) == 2:
            protocols.append('negotiate')

    return protocols


def _create_iov_result(iov):  # type: (IOV) -> Tuple[IOVBuffer, ...]
    """ Converts GSSAPI IOV buffer to generic IOVBuffer result. """
    buffers = []
    for i in iov:
        buffer_entry = IOVBuffer(type=BufferType(i.type), data=i.value)
        buffers.append(buffer_entry)

    return tuple(buffers)


@contextlib.contextmanager
def _env_path(name, value, default_value):  # type: (str, str, str) -> Generator[None, None, None]
    """ Adds a value to a PATH-like env var and preserve the existing value if present. """
    orig_value = os.environ.get(name, None)
    os.environ[name] = '%s:%s' % (value, orig_value or default_value)
    try:
        yield

    finally:
        if orig_value:
            os.environ[name] = orig_value

        else:
            del os.environ[name]


@contextlib.contextmanager
def _krb5_conf(forwardable=False):  # type: (bool) -> Generator[None, None, None]
    """ Runs with a custom krb5.conf file that extends the existing config if present. """
    if forwardable:
        with tempfile.NamedTemporaryFile() as temp_cfg:
            temp_cfg.write(b"[libdefaults]\nforwardable = true\n")
            temp_cfg.flush()

            with _env_path('KRB5_CONFIG', temp_cfg.name, '/etc/krb5.conf'):
                yield

            return

    yield


def _get_gssapi_credential(mech, usage, username=None, password=None, context_req=None):
    # type: (gssapi.OID, str, Optional[text_type], Optional[text_type]) -> gssapi.creds.Credentials
    """Gets a set of credential(s).

    Will get a set of GSSAPI credential(s) for the mech specified. If the username and password is specified then a new
    set of credentials are explicitly required for the mech specified. Otherwise the credentials are retrieved by the
    cache as defined by the mech.

    The behaviour of this function is highly dependent on the GSSAPI implementation installed as well as what NTLM mech
    is available. Here are some of the known behaviours of each mech.

    Kerberos:
        Works for any GSSAPI implementation. The cache is the CCACHE which can be managed with `kinit`.

    NTLM:
        Only works with MIT krb5 and requires `gss-ntlmssp`_ to be installed. The cache that this mech uses is either
        a plaintext file specified by `NTLM_USER_FILE` in the format `DOMAIN:USERNAME:PASSWORD` or
        `:USER_UPN@REALM:PASSWORD` or it can be configured with winbind to a standalone Samba setup or with AD.

    SPNEGO:
        To work properly it requires both Kerberos and NTLM to be available where the latter only works with MIT krb5,
        see `NTLM` for more details. It attempts to get a credential for the all the mechs that SPNEGO supports so it
        will retrieve a Kerberos cred then NTLM.

    Args:
        mech: The mech OID to get the credentials for.
        usage: Either `initiate` for a client context or `accept` for a server context.
        username: The username to get the credentials for, if omitted then the default user is gotten from the cache.
        password: The password for the user, if omitted then the cached credentials is retrieved.

    Returns:
        gssapi.creds.Credentials: The credential set that was created/retrieved.

    .. _gss-ntlmssp:
        https://github.com/gssapi/gss-ntlmssp
    """
    if username:
        name_type = getattr(gssapi.NameType, 'user' if usage == 'initiate' else 'hostbased_service')
        username = gssapi.Name(base=username, name_type=name_type)

    if username and password:
        # NOTE: MIT krb5 < 1.14 would store this cred in the global cache but later versions used a private cache in
        # memory. There's not much we can do about this but document this behaviour and hope people upgrade to a newer
        # version.
        # GSSAPI offers no way to specify custom flags like forwardable. We use a temp conf file to ensure an explicit
        # cred with the delegate flag will actually be forwardable.
        forwardable = False
        forwardable_mechs = [gssapi.OID.from_int_seq(GSSMech.kerberos.value),
                             gssapi.OID.from_int_seq(GSSMech.spnego.value)]
        if context_req and context_req & ContextReq.delegate and mech in forwardable_mechs:
            forwardable = True

        with _krb5_conf(forwardable=forwardable):
            cred = acquire_cred_with_password(username, to_bytes(password), usage=usage, mechs=[mech])

        return cred.creds

    cred = gssapi.Credentials(name=username, usage=usage, mechs=[mech])

    # We don't need to check the actual lifetime, just trying to get the valid will have gssapi check the lifetime and
    # raise an ExpiredCredentialsError if it is expired.
    _ = cred.lifetime

    return cred


def _gss_ntlmssp_available(session_key=False):  # type: (bool) -> bool
    """Determine if NTLM is available through GSSAPI.

    NTLM support through GSSAPI is a complicated story. Because we rely on NTLM being available for SPNEGO fallback
    when Kerberos doesn't work we need to make sure the currently installed provider will give us what we need.

    Here is the current lay of the land for each GSSAPI provider.

    MIT KRB5:
        MIT KRB5 does not have NTLM builtin but it can be added with the `gss-ntlmssp`_ provider. We check to make sure
        the NTLM mech is installed and implements the required functions that are needed for SPNEGO support.

        The `gss-ntlmssp`_ provider only recently added support for retrieving its session key in v0.9.0. Not all
        callers need this behaviour so the `session_key` arg can be used to do a further check on that if needed.

    Heimdal:
        There are 2 major variants for Heimdal; 1. macOS' implementation, and 2. the actual Heimdal distribution. Each
        build has builtin "support" for NTLM but so far they are not usable for this library because:

        * macOS' implementation doesn't produce valid tokens, they are rejected by the server.
        * Pure Heimdal `gss_acquire_cred_with_password` isn't implemented for NTLM, no explicit creds.
        * Doesn't seem to produce a NTLM v2 message so the strength is even less than what our Python impl can offer.
        * It is doubtful it implements the required functions that MIT KRB5 relies on to get SPNEGO working.

        Because of these reasons we don't consider NTLM usable through GSSAPI on Heimdal based setups.

    Args:
        session_key: Whether the caller will want access to the session key of the context.

    Returns:
        bool: Whether NTLM is available to use (True) or not (False).

    .. _gss-ntlmssp:
        https://github.com/gssapi/gss-ntlmssp
    """
    # Cache the result so we don't run this check multiple times.
    try:
        res = _gss_ntlmssp_available.result
        return res['session_key'] if session_key else res['available']
    except AttributeError:
        pass

    ntlm_features = {
        'available': False,
        'session_key': False,
    }

    # If any of these calls results in a GSSError we treat that as NTLM being unusable because these are standard
    # behaviours we expect to work.
    ntlm = gssapi.OID.from_int_seq(GSSMech.ntlm.value)
    try:
        # This can be anything, the first NTLM message doesn't need a valid target name or credential.
        spn = gssapi.Name('http@test', name_type=gssapi.NameType.hostbased_service)
        cred = _get_gssapi_credential(ntlm, 'initiate', username='user', password='pass')
        context = gssapi.SecurityContext(creds=cred, usage='initiate', name=spn, mech=ntlm)

        context.step()  # Need to at least have a context set up before we can call gss_set_sec_context_option.

        # macOS' Heimdal implementation will work up to this point but the end messages aren't actually valid. Luckily
        # it does not implement 'GSS_NTLMSSP_RESET_CRYPTO_OID' so by running this we can weed out that broken impl.
        _gss_ntlmssp_reset_crypto(context)

        ntlm_features['available'] = True
    except GSSError as gss_err:
        log.debug("GSSAPI does not support required the NTLM interfaces: %s" % str(gss_err))
    else:
        # gss-ntlmssp only recently added support for GSS_C_INQ_SSPI_SESSION_KEY in v0.9.0, we check if it is present
        # before declaring session_key support is there as it might control whether it is used or not.
        # https://github.com/gssapi/gss-ntlmssp/issues/10
        try:
            inquire_sec_context_by_oid(context, gssapi.OID.from_int_seq(_GSS_C_INQ_SSPI_SESSION_KEY))
        except gss_errors.OperationUnavailableError as o_err:
            # (GSS_S_UNAVAILABLE | ERR_NOTAVAIL) is raised when ntlmssp does support GSS_C_INQ_SSPI_SESSION key but
            # the context is not yet established. Any other errors would mean this isn't supported and we can't use
            # the current version installed if we need session_key interrogation.
            # https://github.com/gssapi/gss-ntlmssp/blob/9d7a275a4d6494606fb54713876e4f5cbf4d1362/src/gss_sec_ctx.c#L1277
            if getattr(o_err, 'min_code', 0) == 1314127894:  # ERR_NOTAVAIL
                ntlm_features['session_key'] = True

            else:
                log.debug("GSSAPI ntlmssp does not support session key interrogation: %s" % str(o_err))

    _gss_ntlmssp_available.result = ntlm_features
    return _gss_ntlmssp_available(session_key=session_key)


def _gss_ntlmssp_reset_crypto(context, outgoing=True):  # type: (gssapi.SecurityContext, bool) -> None
    """ Resets the NTLM RC4 ciphers when being used with SPNEGO. """
    reset_crypto = gssapi.OID.from_int_seq(_GSS_NTLMSSP_RESET_CRYPTO_OID)
    value = b"\x00\x00\x00\x00" if outgoing else b"\x01\x00\x00\x00"
    set_sec_context_option(reset_crypto, context=context, value=value)


def _gss_sasl_description(mech):  # type: (gssapi.OID) -> Optional[bytes]
    """ Attempts to get the SASL description of the mech specified. """
    try:
        res = _gss_sasl_description.result
        return res[mech.dotted_form]

    except (AttributeError, KeyError):
        res = getattr(_gss_sasl_description, 'result', {})

    try:
        sasl_desc = gssapi.raw.inquire_saslname_for_mech(mech).mech_description
    except Exception as e:
        log.debug("gss_inquire_saslname_for_mech(%s) failed: %s" % (mech.dotted_form, str(e)))
        sasl_desc = None

    res[mech.dotted_form] = sasl_desc
    _gss_sasl_description.result = res
    return _gss_sasl_description(mech)


class GSSAPIProxy(ContextProxy):
    """GSSAPI proxy class for GSSAPI on Linux.

    This proxy class for GSSAPI exposes GSSAPI calls into a common interface for SPNEGO authentication. This context
    uses the Python gssapi library to interface with the gss_* calls to provider Kerberos, and potentially native
    ntlm/negotiate functionality.
    """
    def __init__(self, username=None, password=None, hostname=None, service=None, channel_bindings=None,
                 context_req=ContextReq.default, usage='initiate', protocol='negotiate', options=0, _is_wrapped=False):

        if not HAS_GSSAPI:
            reraise(ImportError("GSSAPIProxy requires the Python gssapi library"), GSSAPI_IMP_ERR)

        super(GSSAPIProxy, self).__init__(username, password, hostname, service, channel_bindings, context_req, usage,
                                          protocol, options, _is_wrapped)

        mech_str = {
            'kerberos': GSSMech.kerberos.value,
            'negotiate': GSSMech.spnego.value,
            'ntlm': GSSMech.ntlm.value,
        }[self.protocol]
        mech = gssapi.OID.from_int_seq(mech_str)

        cred = None
        try:
            cred = _get_gssapi_credential(mech, self.usage, username=username, password=password,
                                          context_req=context_req)
        except GSSError as gss_err:
            reraise(SpnegoError(base_error=gss_err, context_msg="Getting GSSAPI credential"))

        context_kwargs = {}

        if self.channel_bindings:
            context_kwargs['channel_bindings'] = ChannelBindings(
                initiator_address_type=self.channel_bindings.initiator_addrtype,
                initiator_address=self.channel_bindings.initiator_address,
                acceptor_address_type=self.channel_bindings.acceptor_addrtype,
                acceptor_address=self.channel_bindings.acceptor_address,
                application_data=self.channel_bindings.application_data
            )

        if self.usage == 'initiate':
            spn = to_text("%s@%s" % (service.lower() if service else 'host', hostname or 'unspecified'))
            context_kwargs['name'] = gssapi.Name(spn, name_type=gssapi.NameType.hostbased_service)
            context_kwargs['mech'] = mech
            context_kwargs['flags'] = self._context_req

        self._context = gssapi.SecurityContext(creds=cred, usage=self.usage, **context_kwargs)

    @classmethod
    def available_protocols(cls, options=None):
        return _available_protocols(options=options)

    @classmethod
    def iov_available(cls):
        # NOTE: Even if the IOV headers are unavailable, if NTLM was negotiated then IOV won't work. Unfortunately we
        # cannot determine that here as we may not know the protocol until after negotiation.
        return HAS_IOV

    @property
    def client_principal(self):
        if self.usage == 'accept':
            # Looks like a bug in python-gssapi where the value still has the terminating null char.
            return to_text(self._context.initiator_name).rstrip(u'\x00')

    @property
    def complete(self):
        return self._context.complete

    @property
    def negotiated_protocol(self):
        try:
            # For an acceptor this can be blank until the first token is received
            oid = self._context.mech.dotted_form
        except AttributeError:
            return

        return {
            GSSMech.kerberos.value: 'kerberos',
            GSSMech.ntlm.value: 'ntlm',

            # Only set until the negotiate process is complete, will change to one of the above once the context is
            # set up.
            GSSMech.spnego.value: 'negotiate',
        }.get(oid, 'unknown: %s' % self._context.mech.dotted_form)

    @property
    @wrap_system_error(NativeError, "Retrieving session key")
    def session_key(self):
        return inquire_sec_context_by_oid(self._context, gssapi.OID.from_int_seq(_GSS_C_INQ_SSPI_SESSION_KEY))[0]

    @wrap_system_error(NativeError, "Processing security token")
    def step(self, in_token=None):
        if not self._is_wrapped:
            log.debug("GSSAPI step input: %s", to_text(base64.b64encode(in_token or b"")))

        out_token = self._context.step(in_token)
        self._context_attr = int(self._context.actual_flags)

        if not self._is_wrapped:
            log.debug("GSSAPI step output: %s", to_text(base64.b64encode(out_token or b"")))

        return out_token

    @wrap_system_error(NativeError, "Wrapping data")
    def wrap(self, data, encrypt=True, qop=None):
        res = gssapi.raw.wrap(self._context, data, confidential=encrypt, qop=qop)

        # gss-ntlmssp used to hardcode the conf_state=0 which results in encrpted=False. Because we know it is always
        # sealed we just manually set to True.
        # https://github.com/gssapi/gss-ntlmssp/pull/15
        encrypted = True if self.negotiated_protocol == 'ntlm' else res.encrypted

        return WrapResult(data=res.message, encrypted=encrypted)

    @wrap_system_error(NativeError, "Wrapping IOV buffer")
    def wrap_iov(self, iov, encrypt=True, qop=None):
        iov_buffer = IOV(*self._build_iov_list(iov), std_layout=False)
        encrypted = wrap_iov(self._context, iov_buffer, confidential=encrypt, qop=qop)

        return IOVWrapResult(buffers=_create_iov_result(iov_buffer), encrypted=encrypted)

    def wrap_winrm(self, data):
        if self.negotiated_protocol == 'ntlm':
            # NTLM does not support IOV wrapping, luckily the header is a fixed size so we can split at that.
            wrap_result = self.wrap(data).data
            header = wrap_result[:16]
            enc_data = wrap_result[16:]
            padding = b""

        else:
            iov = self.wrap_iov([BufferType.header, data, BufferType.padding]).buffers
            header = iov[0].data
            enc_data = iov[1].data
            padding = iov[2].data or b""

        return WinRMWrapResult(header=header, data=enc_data + padding, padding_length=len(padding))

    @wrap_system_error(NativeError, "Unwrapping data")
    def unwrap(self, data):
        res = gssapi.raw.unwrap(self._context, data)

        # See wrap for more info.
        encrypted = True if self.negotiated_protocol == 'ntlm' else res.encrypted

        return UnwrapResult(data=res.message, encrypted=encrypted, qop=res.qop)

    @wrap_system_error(NativeError, "Unwrapping IOV buffer")
    def unwrap_iov(self, iov):
        iov_buffer = IOV(*self._build_iov_list(iov), std_layout=False)
        res = unwrap_iov(self._context, iov_buffer)

        return IOVUnwrapResult(buffers=_create_iov_result(iov_buffer), encrypted=res.encrypted, qop=res.qop)

    def unwrap_winrm(self, header, data):
        # This is an extremely weird setup, we need to use gss_unwrap for NTLM but for Kerberos it depends on the
        # underlying provider that is used. Right now the proper IOV buffers required to work on both AES and RC4
        # encrypted only works for MIT KRB5 whereas Heimdal fails. It currently mandates a padding buffer of a
        # variable size which we cannot achieve in the way that WinRM encrypts the data. This is fixed in the source
        # code but until it is widely distributed we just need to use a way that is known to just work with AES. To
        # ensure that MIT works on both RC4 and AES we check the description which differs between the 2 implemtations.
        # It's not perfect but I don't know of another way to achieve this until more time has passed.
        # https://github.com/heimdal/heimdal/issues/739
        sasl_desc = _gss_sasl_description(self._context.mech)

        # https://github.com/krb5/krb5/blob/f2e28f13156785851819fc74cae52100e0521690/src/lib/gssapi/krb5/gssapi_krb5.c#L686
        if sasl_desc and sasl_desc == b'Kerberos 5 GSS-API Mechanism':
            # TODO: Should done when self.negotiated_protocol == 'kerberos', above explains why this can't be done yet.
            iov = self.unwrap_iov([
                (IOVBufferType.header, header),
                data,
                IOVBufferType.data
            ]).buffers
            return iov[1].data

        else:
            return self.unwrap(header + data).data

    @wrap_system_error(NativeError, "Signing message")
    def sign(self, data, qop=None):
        return gssapi.raw.get_mic(self._context, data, qop=qop)

    @wrap_system_error(NativeError, "Verifying message")
    def verify(self, data, mic):
        return gssapi.raw.verify_mic(self._context, data, mic)

    @property
    def _context_attr_map(self):
        attr_map = [
            (ContextReq.delegate, 'delegate_to_peer'),
            (ContextReq.mutual_auth, 'mutual_authentication'),
            (ContextReq.replay_detect, 'replay_detection'),
            (ContextReq.sequence_detect, 'out_of_sequence_detection'),
            (ContextReq.confidentiality, 'confidentiality'),
            (ContextReq.integrity, 'integrity'),

            # Only present when the DCE extensions are installed.
            (ContextReq.identify, 'identify'),

            # Only present with newer versions of python-gssapi https://github.com/pythongssapi/python-gssapi/pull/218.
            (ContextReq.delegate_policy, 'ok_as_delegate'),
        ]
        attrs = []
        for spnego_flag, gssapi_name in attr_map:
            if hasattr(gssapi.RequirementFlag, gssapi_name):
                attrs.append((spnego_flag, getattr(gssapi.RequirementFlag, gssapi_name)))

        return attrs

    @property
    def _requires_mech_list_mic(self):
        try:
            require_mic = gssapi.OID.from_int_seq(_GSS_SPNEGO_REQUIRE_MIC_OID_STRING)
            res = inquire_sec_context_by_oid(self._context, require_mic)
        except GSSError:
            # Not all gssapi mechs implement this OID, the other mechListMIC rules still apply but are calc elsewhere.
            return False
        else:
            return b"\x01" in res

    def _convert_iov_buffer(self, iov_buffer):  # type: (IOVBuffer) -> Tuple[int, bool, Optional[bytes]]
        buffer_data = None
        buffer_alloc = False

        if isinstance(iov_buffer.data, bytes):
            buffer_data = iov_buffer.data
        elif isinstance(iov_buffer.data, int):
            # This shouldn't really occur on GSSAPI but is here to mirror what SSPI does.
            buffer_data = b"\x00" * iov_buffer.data
        else:
            auto_alloc = [BufferType.header, BufferType.padding, BufferType.trailer]

            buffer_alloc = iov_buffer.data
            if buffer_alloc is None:
                buffer_alloc = iov_buffer.type in auto_alloc

        return iov_buffer.type, buffer_alloc, buffer_data

    @wrap_system_error(NativeError, "NTLM reset crypto state")
    def _reset_ntlm_crypto_state(self, outgoing=True):
        if self.negotiated_protocol == 'ntlm':
            _gss_ntlmssp_reset_crypto(self._context, outgoing=outgoing)
