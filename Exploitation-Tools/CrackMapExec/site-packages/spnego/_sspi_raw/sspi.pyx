# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from collections import (
    namedtuple,
)

from spnego._text import (
    to_native,
)

from cpython.exc cimport (
    PyErr_SetFromWindowsErr,
)

from libc.stdlib cimport (
    calloc,
    free,
    malloc,
)

from libc.string cimport (
    memcpy,
)

from spnego._sspi_raw.security cimport (
    AcceptSecurityContext,
    AcquireCredentialsHandleW,
    ASC_REQ_DELEGATE,
    ASC_REQ_MUTUAL_AUTH,
    ASC_REQ_REPLAY_DETECT,
    ASC_REQ_SEQUENCE_DETECT,
    ASC_REQ_CONFIDENTIALITY,
    ASC_REQ_USE_SESSION_KEY,
    ASC_REQ_ALLOCATE_MEMORY,
    ASC_REQ_USE_DCE_STYLE,
    ASC_REQ_DATAGRAM,
    ASC_REQ_CONNECTION,
    ASC_REQ_CALL_LEVEL,
    ASC_REQ_FRAGMENT_SUPPLIED,
    ASC_REQ_EXTENDED_ERROR,
    ASC_REQ_STREAM,
    ASC_REQ_INTEGRITY,
    ASC_REQ_LICENSING,
    ASC_REQ_IDENTIFY,
    ASC_REQ_ALLOW_NULL_SESSION,
    ASC_REQ_ALLOW_NON_USER_LOGONS,
    ASC_REQ_ALLOW_CONTEXT_REPLAY,
    ASC_REQ_FRAGMENT_TO_FIT,
    ASC_REQ_NO_TOKEN,
    ASC_REQ_PROXY_BINDINGS,
    ASC_REQ_ALLOW_MISSING_BINDINGS,
    ASC_RET_DELEGATE,
    ASC_RET_MUTUAL_AUTH,
    ASC_RET_REPLAY_DETECT,
    ASC_RET_SEQUENCE_DETECT,
    ASC_RET_CONFIDENTIALITY,
    ASC_RET_USE_SESSION_KEY,
    ASC_RET_ALLOCATED_MEMORY,
    ASC_RET_USED_DCE_STYLE,
    ASC_RET_DATAGRAM,
    ASC_RET_CONNECTION,
    ASC_RET_CALL_LEVEL,
    ASC_RET_THIRD_LEG_FAILED,
    ASC_RET_EXTENDED_ERROR,
    ASC_RET_STREAM,
    ASC_RET_INTEGRITY,
    ASC_RET_LICENSING,
    ASC_RET_IDENTIFY,
    ASC_RET_NULL_SESSION,
    ASC_RET_ALLOW_NON_USER_LOGONS,
    ASC_RET_ALLOW_CONTEXT_REPLAY,
    ASC_RET_FRAGMENT_ONLY,
    ASC_RET_NO_TOKEN,
    ASC_RET_NO_ADDITIONAL_TOKEN,
    CompleteAuthToken,
    CredHandle,
    CtxtHandle,
    DecryptMessage,
    DeleteSecurityContext,
    EncryptMessage,
    FreeContextBuffer,
    FreeCredentialsHandle,
    InitializeSecurityContextW,
    ISC_REQ_ALLOCATE_MEMORY,
    ISC_REQ_CONFIDENTIALITY,
    ISC_REQ_CONNECTION,
    ISC_REQ_DELEGATE,
    ISC_REQ_EXTENDED_ERROR,
    ISC_REQ_IDENTIFY,
    ISC_REQ_INTEGRITY,
    ISC_REQ_MANUAL_CRED_VALIDATION,
    ISC_REQ_MUTUAL_AUTH,
    ISC_REQ_NO_INTEGRITY,
    ISC_REQ_REPLAY_DETECT,
    ISC_REQ_SEQUENCE_DETECT,
    ISC_REQ_STREAM,
    ISC_REQ_USE_SESSION_KEY,
    ISC_REQ_USE_SUPPLIED_CREDS,
    ISC_RET_DELEGATE,
    ISC_RET_MUTUAL_AUTH,
    ISC_RET_REPLAY_DETECT,
    ISC_RET_SEQUENCE_DETECT,
    ISC_RET_CONFIDENTIALITY,
    ISC_RET_USE_SESSION_KEY,
    ISC_RET_USED_COLLECTED_CREDS,
    ISC_RET_USED_SUPPLIED_CREDS,
    ISC_RET_ALLOCATED_MEMORY,
    ISC_RET_USED_DCE_STYLE,
    ISC_RET_DATAGRAM,
    ISC_RET_CONNECTION,
    ISC_RET_INTERMEDIATE_RETURN,
    ISC_RET_CALL_LEVEL,
    ISC_RET_EXTENDED_ERROR,
    ISC_RET_STREAM,
    ISC_RET_INTEGRITY,
    ISC_RET_IDENTIFY,
    ISC_RET_NULL_SESSION,
    ISC_RET_MANUAL_CRED_VALIDATION,
    ISC_RET_FRAGMENT_ONLY,
    ISC_RET_FORWARD_CREDENTIALS,
    ISC_RET_USED_HTTP_STYLE,
    ISC_RET_NO_ADDITIONAL_TOKEN,
    ISC_RET_REAUTHENTICATION,
    MakeSignature,
    PCtxtHandle,
    PSEC_WINNT_AUTH_IDENTITY_W,
    PSecBuffer,
    PSecPkgInfoW,
    QueryContextAttributesW,
    SEC_WINNT_AUTH_IDENTITY_UNICODE,
    SEC_WINNT_AUTH_IDENTITY_W,
    SecBuffer as NativeSecBuffer,
    SecBufferDesc as NativeSecBufferDesc,
    SECBUFFER_VERSION,
    SECBUFFER_EMPTY,
    SECBUFFER_DATA,
    SECBUFFER_TOKEN,
    SECBUFFER_PKG_PARAMS,
    SECBUFFER_MISSING,
    SECBUFFER_EXTRA,
    SECBUFFER_STREAM_TRAILER,
    SECBUFFER_STREAM_HEADER,
    SECBUFFER_NEGOTIATION_INFO,
    SECBUFFER_PADDING,
    SECBUFFER_STREAM,
    SECBUFFER_MECHLIST,
    SECBUFFER_MECHLIST_SIGNATURE,
    SECBUFFER_TARGET,
    SECBUFFER_CHANNEL_BINDINGS,
    SECBUFFER_CHANGE_PASS_RESPONSE,
    SECBUFFER_TARGET_HOST,
    SECBUFFER_ATTRMASK,
    SECBUFFER_READONLY,
    SECBUFFER_READONLY_WITH_CHECKSUM,
    SECBUFFER_RESERVED,
    SecPkgContext_Names,
    SecPkgContext_PackageInfoW,
    SecPkgContext_SessionKey,
    SecPkgContext_Sizes,
    SecPkgInfoW,
    SECPKG_ATTR_NAMES,
    SECPKG_ATTR_PACKAGE_INFO,
    SECPKG_ATTR_SESSION_KEY,
    SECPKG_ATTR_SIZES,
    SECPKG_CRED_BOTH,
    SECPKG_CRED_INBOUND,
    SECPKG_CRED_OUTBOUND,
    SECQOP_WRAP_NO_ENCRYPT,
    SECURITY_INTEGER,
    SECURITY_NATIVE_DREP,
    SECURITY_NETWORK_DREP,
    SEC_E_BUFFER_TOO_SMALL as _SEC_E_BUFFER_TOO_SMALL,
    SEC_E_CONTEXT_EXPIRED as _SEC_E_CONTEXT_EXPIRED,
    SEC_E_CRYPTO_SYSTEM_INVALID as _SEC_E_CRYPTO_SYSTEM_INVALID,
    SEC_E_INCOMPLETE_MESSAGE as _SEC_E_INCOMPLETE_MESSAGE,
    SEC_E_INSUFFICIENT_MEMORY as _SEC_E_INSUFFICIENT_MEMORY,
    SEC_E_INTERNAL_ERROR as _SEC_E_INTERNAL_ERROR,
    SEC_E_INVALID_HANDLE as _SEC_E_INVALID_HANDLE,
    SEC_E_INVALID_TOKEN as _SEC_E_INVALID_TOKEN,
    SEC_E_LOGON_DENIED as _SEC_E_LOGON_DENIED,
    SEC_E_MESSAGE_ALTERED as _SEC_E_MESSAGE_ALTERED,
    SEC_E_NOT_OWNER as _SEC_E_NOT_OWNER,
    SEC_E_NO_AUTHENTICATING_AUTHORITY as _SEC_E_NO_AUTHENTICATING_AUTHORITY,
    SEC_E_NO_CREDENTIALS as _SEC_E_NO_CREDENTIALS,
    SEC_E_OK as _SEC_E_OK,
    SEC_E_OUT_OF_SEQUENCE as _SEC_E_OUT_OF_SEQUENCE,
    SEC_E_QOP_NOT_SUPPORTED as _SEC_E_QOP_NOT_SUPPORTED,
    SEC_E_SECPKG_NOT_FOUND as _SEC_E_SECPKG_NOT_FOUND,
    SEC_E_TARGET_UNKNOWN as _SEC_E_TARGET_UNKNOWN,
    SEC_E_UNKNOWN_CREDENTIALS as _SEC_E_UNKNOWN_CREDENTIALS,
    SEC_E_UNSUPPORTED_FUNCTION as _SEC_E_UNSUPPORTED_FUNCTION,
    SEC_E_WRONG_PRINCIPAL as _SEC_E_WRONG_PRINCIPAL,
    SEC_I_COMPLETE_AND_CONTINUE as _SEC_I_COMPLETE_AND_CONTINUE,
    SEC_I_COMPLETE_NEEDED as _SEC_I_COMPLETE_NEEDED,
    SEC_I_CONTINUE_NEEDED as _SEC_I_CONTINUE_NEEDED,
    SEC_I_INCOMPLETE_CREDENTIALS as _SEC_I_INCOMPLETE_CREDENTIALS,
    VerifySignature,
)

from spnego._sspi_raw.text cimport (
    u16_to_text,
    WideChar,
)


class ClientContextAttr:
    delegate = ISC_RET_DELEGATE
    mutual_auth = ISC_RET_MUTUAL_AUTH
    replay_detect = ISC_RET_REPLAY_DETECT
    sequence_detect = ISC_RET_SEQUENCE_DETECT
    confidentiality = ISC_RET_CONFIDENTIALITY
    use_session_key = ISC_RET_USE_SESSION_KEY
    used_collected_creds = ISC_RET_USED_COLLECTED_CREDS
    used_supplied_creds = ISC_RET_USED_SUPPLIED_CREDS
    allocated_memory = ISC_RET_ALLOCATED_MEMORY
    used_dce_style = ISC_RET_USED_DCE_STYLE
    datagram = ISC_RET_DATAGRAM
    connection = ISC_RET_CONNECTION
    intermediate_return = ISC_RET_INTERMEDIATE_RETURN
    call_level = ISC_RET_CALL_LEVEL
    extended_error = ISC_RET_EXTENDED_ERROR
    stream = ISC_RET_STREAM
    integrity = ISC_RET_INTEGRITY
    identify = ISC_RET_IDENTIFY
    null_session = ISC_RET_NULL_SESSION
    manual_cred_validation = ISC_RET_MANUAL_CRED_VALIDATION
    fragment_only = ISC_RET_FRAGMENT_ONLY
    forward_credentials = ISC_RET_FORWARD_CREDENTIALS
    used_http_style = ISC_RET_USED_HTTP_STYLE
    no_additional_token = ISC_RET_NO_ADDITIONAL_TOKEN
    reauthentication = ISC_RET_REAUTHENTICATION


class ClientContextReq:
    allocate_memory = ISC_REQ_ALLOCATE_MEMORY
    confidentiality = ISC_REQ_CONFIDENTIALITY
    connection = ISC_REQ_CONNECTION
    delegate = ISC_REQ_DELEGATE
    extended_error = ISC_REQ_EXTENDED_ERROR
    http = 0x10000000  # ISC_REQ_HTTP
    integrity = ISC_REQ_INTEGRITY
    identify = ISC_REQ_IDENTIFY
    manual_cred_validation = ISC_REQ_MANUAL_CRED_VALIDATION
    mutual_auth = ISC_REQ_MUTUAL_AUTH
    no_integrity = ISC_REQ_NO_INTEGRITY
    replay_detect = ISC_REQ_REPLAY_DETECT
    sequence_detect = ISC_REQ_SEQUENCE_DETECT
    stream = ISC_REQ_STREAM
    use_session_key = ISC_REQ_USE_SESSION_KEY
    use_supplied_creds = ISC_REQ_USE_SUPPLIED_CREDS


class CredentialUse:
    inbound = SECPKG_CRED_INBOUND
    outbound = SECPKG_CRED_OUTBOUND
    both = SECPKG_CRED_BOTH


class SecBufferType:
    empty = SECBUFFER_EMPTY
    data = SECBUFFER_DATA
    token = SECBUFFER_TOKEN
    pkg_params = SECBUFFER_PKG_PARAMS
    missing = SECBUFFER_MISSING
    extra = SECBUFFER_EXTRA
    stream_trailer = SECBUFFER_STREAM_TRAILER
    stream_header = SECBUFFER_STREAM_HEADER
    negotiation_info = SECBUFFER_NEGOTIATION_INFO
    padding = SECBUFFER_PADDING
    stream = SECBUFFER_STREAM
    mechlist = SECBUFFER_MECHLIST
    mechlist_signature = SECBUFFER_MECHLIST_SIGNATURE
    target = SECBUFFER_TARGET
    channel_bindings = SECBUFFER_CHANNEL_BINDINGS
    change_pass_response = SECBUFFER_CHANGE_PASS_RESPONSE
    target_host = SECBUFFER_TARGET_HOST
    attrmask = SECBUFFER_ATTRMASK
    readonly = SECBUFFER_READONLY
    readonly_with_checksum = SECBUFFER_READONLY_WITH_CHECKSUM
    reserved = SECBUFFER_RESERVED


class SecPkgAttr:
    names = SECPKG_ATTR_NAMES
    package_info = SECPKG_ATTR_PACKAGE_INFO
    session_key = SECPKG_ATTR_SESSION_KEY
    sizes = SECPKG_ATTR_SIZES


class SecStatus:
    SEC_E_BUFFER_TOO_SMALL = _SEC_E_BUFFER_TOO_SMALL
    SEC_E_CONTEXT_EXPIRED = _SEC_E_CONTEXT_EXPIRED
    SEC_E_CRYPTO_SYSTEM_INVALID = _SEC_E_CRYPTO_SYSTEM_INVALID
    SEC_E_INCOMPLETE_MESSAGE = _SEC_E_INCOMPLETE_MESSAGE
    SEC_E_INSUFFICIENT_MEMORY = _SEC_E_INSUFFICIENT_MEMORY
    SEC_E_INTERNAL_ERROR = _SEC_E_INTERNAL_ERROR
    SEC_E_INVALID_HANDLE = _SEC_E_INVALID_HANDLE
    SEC_E_INVALID_TOKEN = _SEC_E_INVALID_TOKEN
    SEC_E_LOGON_DENIED = _SEC_E_LOGON_DENIED
    SEC_E_MESSAGE_ALTERED = _SEC_E_MESSAGE_ALTERED
    SEC_E_NOT_OWNER = _SEC_E_NOT_OWNER
    SEC_E_NO_AUTHENTICATING_AUTHORITY = _SEC_E_NO_AUTHENTICATING_AUTHORITY
    SEC_E_NO_CREDENTIALS = _SEC_E_NO_CREDENTIALS
    SEC_E_OK = _SEC_E_OK
    SEC_E_OUT_OF_SEQUENCE = _SEC_E_OUT_OF_SEQUENCE
    SEC_E_QOP_NOT_SUPPORTED = _SEC_E_QOP_NOT_SUPPORTED
    SEC_E_SECPKG_NOT_FOUND = _SEC_E_SECPKG_NOT_FOUND
    SEC_E_TARGET_UNKNOWN = _SEC_E_TARGET_UNKNOWN
    SEC_E_UNKNOWN_CREDENTIALS = _SEC_E_UNKNOWN_CREDENTIALS
    SEC_E_UNSUPPORTED_FUNCTION = _SEC_E_UNSUPPORTED_FUNCTION
    SEC_E_WRONG_PRINCIPAL = _SEC_E_WRONG_PRINCIPAL
    SEC_I_COMPLETE_AND_CONTINUE = _SEC_I_COMPLETE_AND_CONTINUE
    SEC_I_COMPLETE_NEEDED = _SEC_I_COMPLETE_NEEDED
    SEC_I_CONTINUE_NEEDED = _SEC_I_CONTINUE_NEEDED
    SEC_I_INCOMPLETE_CREDENTIALS = _SEC_I_INCOMPLETE_CREDENTIALS


class ServerContextAttr:
    delegate = ASC_RET_DELEGATE
    mutual_auth = ASC_RET_MUTUAL_AUTH
    replay_detect = ASC_RET_REPLAY_DETECT
    sequence_detect = ASC_RET_SEQUENCE_DETECT
    confidentiality = ASC_RET_CONFIDENTIALITY
    use_session_key = ASC_RET_USE_SESSION_KEY
    allocated_memory = ASC_RET_ALLOCATED_MEMORY
    used_dce_style = ASC_RET_USED_DCE_STYLE
    datagram = ASC_RET_DATAGRAM
    connection = ASC_RET_CONNECTION
    call_level = ASC_RET_CALL_LEVEL
    third_leg_failed = ASC_RET_THIRD_LEG_FAILED
    extended_error = ASC_RET_EXTENDED_ERROR
    stream = ASC_RET_STREAM
    integrity = ASC_RET_INTEGRITY
    licensing = ASC_RET_LICENSING
    identify = ASC_RET_IDENTIFY
    null_session = ASC_RET_NULL_SESSION
    allow_non_user_logons = ASC_RET_ALLOW_NON_USER_LOGONS
    allow_context_replay = ASC_RET_ALLOW_CONTEXT_REPLAY
    fragment_only = ASC_RET_FRAGMENT_ONLY
    no_token = ASC_RET_NO_TOKEN
    no_additional_token = ASC_RET_NO_ADDITIONAL_TOKEN


class ServerContextReq:
    delegate = ASC_REQ_DELEGATE
    mutual_auth = ASC_REQ_MUTUAL_AUTH
    replay_detect = ASC_REQ_REPLAY_DETECT
    sequence_detect = ASC_REQ_SEQUENCE_DETECT
    confidentiality = ASC_REQ_CONFIDENTIALITY
    use_session_key = ASC_REQ_USE_SESSION_KEY
    allocate_memory = ASC_REQ_ALLOCATE_MEMORY
    use_dce_style = ASC_REQ_USE_DCE_STYLE
    datagram = ASC_REQ_DATAGRAM
    connection = ASC_REQ_CONNECTION
    call_level = ASC_REQ_CALL_LEVEL
    fragment_supplied = ASC_REQ_FRAGMENT_SUPPLIED
    extended_error = ASC_REQ_EXTENDED_ERROR
    stream = ASC_REQ_STREAM
    integrity = ASC_REQ_INTEGRITY
    licensing = ASC_REQ_LICENSING
    identify = ASC_REQ_IDENTIFY
    allow_null_session = ASC_REQ_ALLOW_NULL_SESSION
    allow_non_user_logons = ASC_REQ_ALLOW_NON_USER_LOGONS
    allow_context_replay = ASC_REQ_ALLOW_CONTEXT_REPLAY
    fragment_to_fit = ASC_REQ_FRAGMENT_TO_FIT
    no_token = ASC_REQ_NO_TOKEN
    proxy_bindings = ASC_REQ_PROXY_BINDINGS
    allow_missing_binding = ASC_REQ_ALLOW_MISSING_BINDINGS


class SSPIQoP:
    wrap_no_encrypt = SECQOP_WRAP_NO_ENCRYPT


class TargetDataRep:
    native = SECURITY_NATIVE_DREP
    network = SECURITY_NETWORK_DREP


SecPkgAttrSizes = namedtuple('SecPkgAttrSizes', ['max_token', 'max_signature', 'block_size', 'security_trailer'])
SecPkgInfo = namedtuple('SecPkgInfo', ['capabilities', 'version', 'rpcid', 'max_token', 'name', 'comment'])


cdef class Credential:

    def __cinit__(Credential self):
        self.expiry = 0

    def __dealloc__(Credential self):
        if self.expiry:
            FreeCredentialsHandle(&self.handle)


cdef class SecurityContext:

    def __cinit__(SecurityContext self):
        self.context_attr = 0
        self.expiry = 0
        self.init = 0

    def __dealloc__(SecurityContext self):
        if self.init:
            DeleteSecurityContext(&self.handle)


cdef class SecBufferDesc:

    def __cinit__(SecBufferDesc self, list buffers not None, unsigned long version=SECBUFFER_VERSION):
        self._c_value = NativeSecBufferDesc(version, <unsigned long>len(buffers), NULL)
        self._buffers = buffers

        if buffers:
            self._c_value.pBuffers = <PSecBuffer>malloc(sizeof(NativeSecBuffer) * len(buffers))
            if not self._c_value.pBuffers:
                raise MemoryError("Cannot malloc SecBufferDesc buffer")

            for idx, buffer in enumerate(buffers):
                self[idx] = buffer

    cdef PSecBufferDesc __c_value__(SecBufferDesc self):
        return &self._c_value

    def __len__(SecBufferDesc self):
        return self._c_value.cBuffers

    def __getitem__(SecBufferDesc self, key):
        return self._buffers[key]

    def __setitem__(SecBufferDesc self, key, SecBuffer value not None):
        value.replace_ptr(&self._c_value.pBuffers[key])

    def __iter__(SecBufferDesc self):
        for val in self._buffers:
            yield val

    def __repr__(SecBufferDesc self):
        return "<{0}.{1}(ulVersion={2}, cBuffers={3})>".format(type(self).__module__, type(self).__name__,
            self._c_value.ulVersion, self._c_value.cBuffers)

    def __str__(SecBufferDesc self):
        return "{0}(ulVersion={1}, cBuffers={2})".format(type(self).__name__, self._c_value.ulVersion,
            self._c_value.cBuffers)

    @property
    def version(SecBufferDesc self):
        return self._c_value.ulVersion

    @version.setter
    def version(SecBufferDesc self, unsigned long value):
        self._c_value.ulVersion = value

    def __dealloc__(SecBufferDesc self):
        if self._c_value.pBuffers:
            free(self._c_value.pBuffers)
            self._c_value.pBuffers = NULL


cdef class SecBuffer:

    def __cinit__(SecBuffer self, unsigned long buffer_type, bytes buffer=None, unsigned long length=0):
        if buffer and length:
            raise ValueError("Only an empty buffer can be created with length")

        self.sys_alloc = 0
        self._is_owner = 1

        self.c_value = <PSecBuffer>calloc(1, sizeof(NativeSecBuffer))
        if not self.c_value:
            raise MemoryError("Cannot malloc SecBuffer buffer")  # pragma: no cover

        self.buffer_type = buffer_type
        if buffer:
            self.buffer = buffer
        elif length:
            self._alloc_buffer(length)

    cdef replace_ptr(SecBuffer self, PSecBuffer ptr):
        # Copy the existing C buffer to the new pointer and free the memory this object was managing.
        memcpy(ptr, self.c_value, sizeof(NativeSecBuffer))
        free(self.c_value)

        # Make sure that this obj does not try and free the new pointer that was passed in (it is up to the caller to
        # do that).
        self._is_owner = 0
        self.c_value = ptr

    def __len__(SecBuffer self):
        return self.c_value.cbBuffer if self.c_value else 0

    def __repr__(SecBuffer self):
        return "<{0}.{1}(cbBuffer={2}, BufferType={3}, pvBuffer={4})>".format(
            type(self).__module__, type(self).__name__, self.c_value.cbBuffer, self.c_value.BufferType,
            repr(self.buffer))

    def __str__(SecBuffer self):
        return "{0}(cbBuffer={1}, BufferType={2}, pvBuffer={3!r})".format(type(self).__name__, self.c_value.cbBuffer,
            self.c_value.BufferType, self.buffer)

    @property
    def buffer_type(SecBuffer self):
        return self.c_value.BufferType

    @buffer_type.setter
    def buffer_type(SecBuffer self, unsigned long value):
        self.c_value.BufferType = value

    @property
    def buffer(SecBuffer self):
        if self.c_value.cbBuffer and self.c_value.pvBuffer:
            return (<char *>self.c_value.pvBuffer)[:self.c_value.cbBuffer]
        elif self.c_value.pvBuffer:
            return b""  # The size was 0 but pvBuffer was not a NULL pointer.
        else:
            return

    @buffer.setter
    def buffer(SecBuffer self, bytes value):
        value_len = len(value)
        self._alloc_buffer(value_len)
        memcpy(self.c_value.pvBuffer, <char *>value, value_len)

    def _alloc_buffer(SecBuffer self, unsigned long length):
        self._dealloc_buffer()

        # We store our allocated memory pointer so we know when we free we are freeing what we allocated.
        self._p_buffer = malloc(length)
        if not self._p_buffer:
            raise MemoryError("Cannot malloc SecBuffer buffer")  # pragma: no cover

        self.c_value.pvBuffer = self._p_buffer
        self.c_value.cbBuffer = length

    def _dealloc_buffer(SecBuffer self):
        # We do need to check if the actual C struct pvBuffer was allocated by Windows and call FreeContextBuffer on
        # that.
        if self.c_value != NULL and self.c_value.pvBuffer != NULL and self.sys_alloc:
            FreeContextBuffer(self.c_value.pvBuffer)

        if self.c_value:
            self.c_value.pvBuffer = NULL

        # Because the C struct pvBuffer may have a pointer set by Windows we track our allocated memory using an
        # internal attribute which we free().
        if self._p_buffer:
            free(self._p_buffer)
        self._p_buffer = NULL

    def __dealloc__(SecBuffer self):
        self._dealloc_buffer()

        if self.c_value != NULL and self._is_owner:
            free(self.c_value)

        self.c_value = NULL


cdef class _AuthIdentityBase:

    cdef void *__c_value__(_AuthIdentityBase self):
        return NULL


cdef class WinNTAuthIdentity(_AuthIdentityBase):

    def __cinit__(WinNTAuthIdentity self, unicode username, unicode domain, unicode password):
        self.c_value.Flags = SEC_WINNT_AUTH_IDENTITY_UNICODE
        self.username = username
        self.domain = domain
        self.password = password

    def __repr__(WinNTAuthIdentity self):
        domain = u"%s\\" % self.domain if self.domain else u""

        return to_native(u"<{0}.{1} {2}{3}>".format(type(self).__module__, type(self).__name__, domain,
            self.username or u""))

    def __str__(WinNTAuthIdentity self):
        domain = u"%s\\" % self.domain if self.domain else u""

        return to_native(u"{0}{1}".format(domain, self.username or u""))

    @property
    def username(WinNTAuthIdentity self):
        return self._username.to_text(self.c_value.UserLength)

    @username.setter
    def username(WinNTAuthIdentity self, unicode value):
        self._username = WideChar.from_text(value)
        self.c_value.User = <void *>self._username.buffer
        self.c_value.UserLength = max(self._username.length - 1, 0)

    @property
    def domain(WinNTAuthIdentity self):
        return self._domain.to_text(self.c_value.DomainLength)

    @domain.setter
    def domain(WinNTAuthIdentity self, unicode value):
        self._domain = WideChar.from_text(value)
        self.c_value.Domain = <void *>self._domain.buffer
        self.c_value.DomainLength = max(self._domain.length - 1, 0)

    @property
    def password(WinNTAuthIdentity self):
        return self._password.to_text(self.c_value.PasswordLength)

    @password.setter
    def password(WinNTAuthIdentity self, unicode value):
        self._password = WideChar.from_text(value)
        self.c_value.Password = <void *>self._password.buffer
        self.c_value.PasswordLength = max(self._password.length - 1, 0)

    cdef void *__c_value__(WinNTAuthIdentity self):
        return &self.c_value

    def __dealloc__(WinNTAuthIdentity self):
        self.username = None
        self.domain = None
        self.password = None


def accept_security_context(Credential credential not None, SecurityContext context not None,
    SecBufferDesc input_buffer=None, unsigned long context_req=0, unsigned long target_data_rep=SECURITY_NATIVE_DREP,
    SecBufferDesc output_buffer=None):

    cdef PCtxtHandle input_context = &context.handle if context.init else NULL
    cdef PSecBufferDesc input = input_buffer.__c_value__() if input_buffer else NULL
    cdef PSecBufferDesc output = output_buffer.__c_value__() if output_buffer else NULL
    cdef SECURITY_INTEGER expiry

    for buffer in (output_buffer or []):
        if len((<SecBuffer>buffer)) == 0:
            context_req |= ISC_REQ_ALLOCATE_MEMORY
            (<SecBuffer>buffer).sys_alloc = 1

    res = AcceptSecurityContext(&credential.handle, input_context, input, context_req, target_data_rep,
        &context.handle, output, &context.context_attr, &expiry)

    if res in [_SEC_I_COMPLETE_AND_CONTINUE, _SEC_I_COMPLETE_NEEDED]:
        res = CompleteAuthToken(&context.handle, output)

    if res not in [_SEC_I_CONTINUE_NEEDED, _SEC_E_OK]:
        PyErr_SetFromWindowsErr(res)

    context.expiry = (<unsigned long long>expiry.HighPart << 32) | expiry.LowPart
    context.init = 1

    return res


def acquire_credentials_handle(unicode principal, unicode package not None,
    unsigned long credential_use=SECPKG_CRED_OUTBOUND, _AuthIdentityBase auth_data=None):

    cdef WideChar w_principal = WideChar.from_text(principal)
    cdef WideChar w_package = WideChar.from_text(package)
    cdef void *p_auth_data = auth_data.__c_value__() if auth_data else NULL
    cdef Credential cred = Credential()
    cdef SECURITY_INTEGER expiry

    res = AcquireCredentialsHandleW(w_principal.buffer, w_package.buffer, credential_use, NULL, p_auth_data, NULL,
        NULL, &cred.handle, &expiry)

    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    cred.expiry = (<unsigned long long>expiry.HighPart << 32) | expiry.LowPart

    return cred


def decrypt_message(SecurityContext context not None, SecBufferDesc message not None, unsigned long seq_no=0):
    cdef unsigned long qop = 0;

    res = DecryptMessage(&context.handle, message.__c_value__(), seq_no, &qop)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    return qop


def encrypt_message(SecurityContext context not None, SecBufferDesc message not None, unsigned long seq_no=0,
    unsigned long qop=0):

    res = EncryptMessage(&context.handle, qop, message.__c_value__(), seq_no)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)


def initialize_security_context(Credential credential not None, SecurityContext context not None,
    unicode target_name not None, unsigned long context_req=0, SecBufferDesc input_buffer=None,
    unsigned long target_data_rep=SECURITY_NATIVE_DREP, SecBufferDesc output_buffer=None):

    cdef PCtxtHandle input_context = &context.handle if context.init else NULL
    cdef WideChar w_target_name = WideChar.from_text(target_name)
    cdef PSecBufferDesc input = input_buffer.__c_value__() if input_buffer else NULL
    cdef PSecBufferDesc output = output_buffer.__c_value__() if output_buffer else NULL
    cdef SECURITY_INTEGER expiry

    for buffer in (output_buffer or []):
        if len((<SecBuffer>buffer)) == 0:
            context_req |= ISC_REQ_ALLOCATE_MEMORY
            (<SecBuffer>buffer).sys_alloc = 1

    res = InitializeSecurityContextW(&credential.handle, input_context, w_target_name.buffer, context_req, 0,
        target_data_rep, input, 0, &context.handle, output, &context.context_attr, &expiry)

    if res in [_SEC_I_COMPLETE_AND_CONTINUE, _SEC_I_COMPLETE_NEEDED]:
        res = CompleteAuthToken(&context.handle, output)

    if res not in [_SEC_I_CONTINUE_NEEDED, _SEC_E_OK]:
        PyErr_SetFromWindowsErr(res)

    context.expiry = (<unsigned long long>expiry.HighPart << 32) | expiry.LowPart
    context.init = 1

    return res


def make_signature(SecurityContext context not None, unsigned long qop, SecBufferDesc message not None,
    unsigned long seq_no=0):

    res = MakeSignature(&context.handle, qop, message.__c_value__(), seq_no)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)


def query_context_attributes(SecurityContext context not None, unsigned long attribute):
    if attribute not in [SecPkgAttr.names, SecPkgAttr.package_info, SecPkgAttr.session_key, SecPkgAttr.sizes]:
        raise NotImplementedError("Only names, package_info, session_key, or sizes is implemented")

    if attribute == SecPkgAttr.names:
        return _query_context_names(context)

    elif attribute == SecPkgAttr.package_info:
        return _query_context_package_info(context)

    elif attribute == SecPkgAttr.session_key:
        return _query_context_session_key(context)

    else:
        return _query_context_sizes(context)


def _query_context_names(SecurityContext context not None):
    cdef SecPkgContext_Names info

    res = QueryContextAttributesW(&context.handle, SecPkgAttr.names, &info)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    try:
        return u16_to_text(info.sUserName, -1)
    finally:
        FreeContextBuffer(<void*>info.sUserName)

def _query_context_package_info(SecurityContext context not None):
    cdef SecPkgContext_PackageInfoW raw_info
    cdef PSecPkgInfoW info

    res = QueryContextAttributesW(&context.handle, SecPkgAttr.package_info, &raw_info)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    try:
        info = <PSecPkgInfoW>raw_info.PackageInfo
        return SecPkgInfo(info.fCapabilities, info.wVersion, info.wRPCID, info.cbMaxToken, u16_to_text(info.Name, -1),
            u16_to_text(info.Comment, -1))
    finally:
        FreeContextBuffer(<void*>raw_info.PackageInfo)


def _query_context_session_key(SecurityContext context not None):
    cdef SecPkgContext_SessionKey info

    res = QueryContextAttributesW(&context.handle, SecPkgAttr.session_key, &info)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    try:
        return (<char *>info.SessionKey)[:info.SessionKeyLength]
    finally:
        FreeContextBuffer(info.SessionKey)


def _query_context_sizes(SecurityContext context not None):
    cdef SecPkgContext_Sizes sizes

    res = QueryContextAttributesW(&context.handle, SecPkgAttr.sizes, &sizes)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    return SecPkgAttrSizes(sizes.cbMaxToken, sizes.cbMaxSignature, sizes.cbBlockSize, sizes.cbSecurityTrailer)


def verify_signature(SecurityContext context not None, SecBufferDesc message not None, unsigned long seq_no=0):
    cdef unsigned long qop = 0

    res = VerifySignature(&context.handle, message.__c_value__(), seq_no, &qop)
    if res != _SEC_E_OK:
        PyErr_SetFromWindowsErr(res)

    return qop
