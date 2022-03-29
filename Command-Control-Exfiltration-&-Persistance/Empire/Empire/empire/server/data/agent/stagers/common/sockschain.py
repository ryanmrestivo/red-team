#!/usr/bin/python
"""SocksiPy - Python SOCKS module.
Version 2.1

Copyright 2011-2019 Bjarni R. Einarsson. All rights reserved.
Copyright 2006 Dan-Haim. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of Dan Haim nor the names of his contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY DAN HAIM "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL DAN HAIM OR HIS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMANGE.


This module provides a standard socket-like interface for Python
for tunneling connections through SOCKS proxies.

"""

"""

Refactored to allow proxy chaining and use as a command-line netcat-like
tool by Bjarni R. Einarsson (http://bre.klaki.net/) for use with PageKite
(http://pagekite.net/).

Minor modifications made by Christopher Gilbert (http://motomastyle.com/)
for use in PyLoris (http://pyloris.sourceforge.net/)

Minor modifications made by Mario Vilas (http://breakingcode.wordpress.com/)
mainly to merge bug fixes found in Sourceforge

"""

import base64, errno, os, socket, sys, select, struct, threading

PY2 = ((2, 0) < sys.version_info < (3, 0))
if PY2:
    b = lambda s: s
else:
    b = lambda s: s.encode('latin-1')

DEBUG = False
DEFAULT_TIMEOUT = 30
#def DEBUG(foo): print foo


##[ SSL compatibility code ]##################################################

import hashlib
def sha1hex(data):
  hl = hashlib.sha1()
  hl.update(data)
  return hl.hexdigest().lower()


def SSL_CheckName(commonName, digest, valid_names):
    try:
      digest = str(digest, 'iso-8859-1')
    except TypeError:
      pass
    digest = digest.replace(':', '')
    pairs = [(commonName, '%s/%s' % (commonName, digest))]
    valid = 0

    if commonName.startswith('*.'):
        commonName = commonName[1:].lower()
        for name in valid_names:
            name = name.split('/')[0].lower()
            if ('.'+name).endswith(commonName):
                pairs.append((name, '%s/%s' % (name, digest)))

    for commonName, cNameDigest in pairs:
        if ((commonName in valid_names) or (cNameDigest in valid_names)):
            valid += 1

    if DEBUG: DEBUG(('*** Cert score: %s (%s ?= %s)'
                     ) % (valid, pairs, valid_names))
    return valid


HAVE_SSL = False
HAVE_PYOPENSSL = False
TLS_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt"
try:
    if sys.version_info >= (3, ):
        raise ImportError('pyOpenSSL disabled (Python 3)')
    if '--nopyopenssl' in sys.argv or '--nossl' in sys.argv:
        raise ImportError('pyOpenSSL disabled')

    from OpenSSL import SSL
    HAVE_SSL = HAVE_PYOPENSSL = True

    def SSL_Connect(ctx, sock,
                    server_side=False, accepted=False, connected=False,
                    verify_names=None):
        if DEBUG: DEBUG('*** TLS is provided by pyOpenSSL')
        if verify_names:
            def vcb(conn, x509, errno, depth, rc):
                if errno != 0: return False
                if depth != 0: return True
                return (SSL_CheckName(x509.get_subject().commonName.lower(),
                                      x509.digest('sha1'),
                                      verify_names) > 0)
            ctx.set_verify(SSL.VERIFY_PEER |
                           SSL.VERIFY_FAIL_IF_NO_PEER_CERT, vcb)
        else:
            def vcb(conn, x509, errno, depth, rc): return (errno == 0)
            ctx.set_verify(SSL.VERIFY_NONE, vcb)

        nsock = SSL.Connection(ctx, sock)
        if accepted: nsock.set_accept_state()
        if connected: nsock.set_connect_state()
        if verify_names: nsock.do_handshake()

        return nsock

except ImportError:
    try:
        if '--nossl' in sys.argv:
            raise ImportError('SSL disabled')

        import ssl
        HAVE_SSL = True

        class SSL(object):
            TLSv1_METHOD = ssl.PROTOCOL_TLSv1
            WantReadError = ssl.SSLError
            class Error(Exception): pass
            class SysCallError(Exception): pass
            class WantWriteError(Exception): pass
            class ZeroReturnError(Exception): pass
            class Context(object):
                def __init__(self, method):
                    self.method = method
                    self.privatekey_file = None
                    self.certchain_file = None
                    self.ca_certs = None
                    self.ciphers = None
                    self.options = 0
                def use_privatekey_file(self, fn):
                    self.privatekey_file = fn
                def use_certificate_chain_file(self, fn):
                    self.certchain_file = fn
                def set_cipher_list(self, ciphers):
                    self.ciphers = ciphers
                def load_verify_locations(self, pemfile, capath=None):
                    self.ca_certs = pemfile
                def set_options(self, options):  # FIXME: this does nothing
                    self.options = options

        if hasattr(ssl, 'PROTOCOL_SSLv23'):
            SSL.SSLv23_METHOD = ssl.PROTOCOL_SSLv23
        if hasattr(ssl, 'OP_NO_SSLv2'):
            SSL.OP_NO_SSLv2 = ssl.OP_NO_SSLv2
        if hasattr(ssl, 'OP_NO_SSLv3'):
            SSL.OP_NO_SSLv3 = ssl.OP_NO_SSLv3
        if hasattr(ssl, 'OP_NO_COMPRESSION'):
            SSL.OP_NO_COMPRESSION = ssl.OP_NO_COMPRESSION
        if hasattr(ssl, 'PROTOCOL_TLS'):
            SSL.TLS_METHOD = ssl.PROTOCOL_TLS

        def SSL_CheckPeerName(fd, names):
            cert = fd.getpeercert()
            certhash = sha1hex(fd.getpeercert(binary_form=True))
            if not cert: return None
            valid = 0
            for field in cert['subject']:
                if field[0][0].lower() == 'commonname':
                    valid += SSL_CheckName(field[0][1].lower(), certhash, names)

            if 'subjectAltName' in cert:
                for field in cert['subjectAltName']:
                    if field[0].lower() == 'dns':
                        name = field[1].lower()
                        valid += SSL_CheckName(name, certhash, names)

            return (valid > 0)

        def SSL_Connect(ctx, sock,
                        server_side=False, accepted=False, connected=False,
                        verify_names=None):
            if DEBUG: DEBUG('*** TLS is provided by native Python ssl')
            reqs = (verify_names and ssl.CERT_REQUIRED or ssl.CERT_NONE)
            try:
                fd = ssl.wrap_socket(sock, keyfile=ctx.privatekey_file,
                                           certfile=ctx.certchain_file,
                                           cert_reqs=reqs,
                                           ca_certs=ctx.ca_certs,
                                           do_handshake_on_connect=False,
                                           ssl_version=ctx.method,
                                           ciphers=ctx.ciphers,
                                           server_side=server_side)
            except:
                fd = ssl.wrap_socket(sock, keyfile=ctx.privatekey_file,
                                           certfile=ctx.certchain_file,
                                           cert_reqs=reqs,
                                           ca_certs=ctx.ca_certs,
                                           do_handshake_on_connect=False,
                                           ssl_version=ctx.method,
                                           server_side=server_side)

            if verify_names:
                fd.do_handshake()
                if not SSL_CheckPeerName(fd, verify_names):
                    raise SSL.Error(('Cert not in %s (%s)'
                                     ) % (verify_names, reqs))
            return fd

    except ImportError:
        class SSL(object):
            # Mock to let our try/except clauses below not fail.
            class Error(Exception): pass
            class SysCallError(Exception): pass
            class WantReadError(Exception): pass
            class WantWriteError(Exception): pass
            class ZeroReturnError(Exception): pass


def DisableSSLCompression():
    # Why? Disabling compression in OpenSSL may reduce memory usage *lots*.

    # If there is a sslzliboff module available, prefer that.
    # See https://github.com/hausen/SSLZlibOff for working code.
    try:
        import sslzliboff
        sslzliboff.disableZlib()
        return
    except:
        pass

    # Otherwise, fall through to the following hack.
    # Source:
    #   http://journal.paul.querna.org/articles/2011/04/05/openssl-memory-use/
    try:
        import ctypes
        import glob
        openssl = ctypes.CDLL(None, ctypes.RTLD_GLOBAL)
        try:
            f = openssl.SSL_COMP_get_compression_methods
        except AttributeError:
            ssllib = sorted(glob.glob("/usr/lib/libssl.so.*"))[0]
            openssl = ctypes.CDLL(ssllib, ctypes.RTLD_GLOBAL)

        openssl.SSL_COMP_get_compression_methods.restype = ctypes.c_void_p
        openssl.sk_zero.argtypes = [ctypes.c_void_p]
        openssl.sk_zero(openssl.SSL_COMP_get_compression_methods())
    except Exception:
        if DEBUG: DEBUG('disableSSLCompression: Failed')


def MakeBestEffortSSLContext(weak=False, legacy=False, anonymous=False,
                             ciphers=None):
    ssl_version, ssl_options = SSL.TLSv1_METHOD, 0
    if hasattr(SSL, 'SSLv23_METHOD') and (weak or legacy):
        ssl_version = SSL.SSLv23_METHOD

    if hasattr(SSL, 'OP_NO_SSLv2') and not weak:
        ssl_version = SSL.SSLv23_METHOD
        ssl_options |= SSL.OP_NO_SSLv2
    if hasattr(SSL, 'OP_NO_SSLv3') and not (weak or legacy):
        ssl_version = SSL.SSLv23_METHOD
        ssl_options |= SSL.OP_NO_SSLv3
    if hasattr(SSL, 'TLS_METHOD') and not (weak or legacy):
        ssl_version = SSL.TLS_METHOD

    if hasattr(SSL, 'OP_NO_COMPRESSION'):
        ssl_options |= SSL.OP_NO_COMPRESSION

    if not ciphers:
        if anonymous:
            # Insecure and use anon ciphers - this is just camoflage
            ciphers = 'aNULL'
        else:
            ciphers = 'HIGH:-aNULL:-eNULL:-PSK:RC4-SHA:RC4-MD5'

    if DEBUG: DEBUG('*** Context: ssl_version=%x, ssl_options=%x, ciphers=%s'
                    % (ssl_version, ssl_options, ciphers))
    ctx = SSL.Context(ssl_version)
    ctx.set_options(ssl_options)
    ctx.set_cipher_list(ciphers)
    return ctx


##[ SocksiPy itself ]#########################################################

PROXY_TYPE_DEFAULT = -1
PROXY_TYPE_NONE = 0
PROXY_TYPE_SOCKS4 = 1
PROXY_TYPE_SOCKS5 = 2
PROXY_TYPE_HTTP = 3
PROXY_TYPE_SSL = 4
PROXY_TYPE_SSL_WEAK = 5
PROXY_TYPE_SSL_ANON = 6
PROXY_TYPE_TOR = 7
PROXY_TYPE_HTTPS = 8
PROXY_TYPE_HTTP_CONNECT = 9
PROXY_TYPE_HTTPS_CONNECT = 10

PROXY_SSL_TYPES = (PROXY_TYPE_SSL, PROXY_TYPE_SSL_WEAK,
                   PROXY_TYPE_SSL_ANON, PROXY_TYPE_HTTPS,
                   PROXY_TYPE_HTTPS_CONNECT)
PROXY_HTTP_TYPES = (PROXY_TYPE_HTTP, PROXY_TYPE_HTTPS)
PROXY_HTTPC_TYPES = (PROXY_TYPE_HTTP_CONNECT, PROXY_TYPE_HTTPS_CONNECT)
PROXY_SOCKS5_TYPES = (PROXY_TYPE_SOCKS5, PROXY_TYPE_TOR)
PROXY_DEFAULTS = {
    PROXY_TYPE_NONE: 0,
    PROXY_TYPE_DEFAULT: 0,
    PROXY_TYPE_HTTP: 8080,
    PROXY_TYPE_HTTP_CONNECT: 8080,
    PROXY_TYPE_SOCKS4: 1080,
    PROXY_TYPE_SOCKS5: 1080,
    PROXY_TYPE_TOR: 9050,
}
PROXY_TYPES = {
  'none': PROXY_TYPE_NONE,
  'default': PROXY_TYPE_DEFAULT,
  'defaults': PROXY_TYPE_DEFAULT,
  'http': PROXY_TYPE_HTTP,
  'httpc': PROXY_TYPE_HTTP_CONNECT,
  'socks': PROXY_TYPE_SOCKS5,
  'socks4': PROXY_TYPE_SOCKS4,
  'socks4a': PROXY_TYPE_SOCKS4,
  'socks5': PROXY_TYPE_SOCKS5,
  'tor': PROXY_TYPE_TOR,
}

if HAVE_SSL:
    PROXY_DEFAULTS.update({
        PROXY_TYPE_HTTPS: 443,
        PROXY_TYPE_HTTPS_CONNECT: 443,
        PROXY_TYPE_SSL: 443,
        PROXY_TYPE_SSL_WEAK: 443,
        PROXY_TYPE_SSL_ANON: 443,
    })
    PROXY_TYPES.update({
        'https': PROXY_TYPE_HTTPS,
        'httpcs': PROXY_TYPE_HTTPS_CONNECT,
        'ssl': PROXY_TYPE_SSL,
        'ssl-anon': PROXY_TYPE_SSL_ANON,
        'ssl-weak': PROXY_TYPE_SSL_WEAK,
    })

P_TYPE = 0
P_HOST = 1
P_PORT = 2
P_RDNS = 3
P_USER = 4
P_PASS = P_CACERTS = 5
P_CERTS = 6

DEFAULT_ROUTE = '*'
_proxyroutes = { }
_orgsocket = socket.socket
_orgcreateconn = getattr(socket, 'create_connection', None)
_thread_locals = threading.local()


class ProxyError(Exception): pass
class GeneralProxyError(ProxyError): pass
class Socks5AuthError(ProxyError): pass
class Socks5Error(ProxyError): pass
class Socks4Error(ProxyError): pass
class HTTPError(ProxyError): pass

_generalerrors = ("success",
    "invalid data",
    "not connected",
    "not available",
    "bad proxy type",
    "bad input")

_socks5errors = ("succeeded",
    "general SOCKS server failure",
    "connection not allowed by ruleset",
    "Network unreachable",
    "Host unreachable",
    "Connection refused",
    "TTL expired",
    "Command not supported",
    "Address type not supported",
    "Unknown error")

_socks5autherrors = ("succeeded",
    "authentication is required",
    "all offered authentication methods were rejected",
    "unknown username or invalid password",
    "unknown error")

_socks4errors = ("request granted",
    "request rejected or failed",
    "request rejected because SOCKS server cannot connect to identd on the client",
    "request rejected because the client program and identd report different user-ids",
    "unknown error")


def parseproxy(arg):
    # This silly function will do a quick-and-dirty parse of our argument
    # into a proxy specification array. It lets people omit stuff.
    if '!' in arg:
      # Prefer ! to :, because it works with IPv6 addresses.
      args = arg.split('!')
    else:
      # This is a bit messier to accept common URL syntax
      if arg.endswith('/'):
        arg = arg[:-1]
      args = arg.replace('://', ':').replace('/:', ':').split(':')
    args[0] = PROXY_TYPES[args[0] or 'http']

    if (len(args) in (3, 4, 5)) and ('@' in args[2]):
        # Re-order http://user:pass@host:port/ => http:host:port:user:pass
        pwd, host = args[2].split('@')
        user = args[1]
        args[1:3] = [host]
        if len(args) == 2: args.append(PROXY_DEFAULTS[args[0]])
        if len(args) == 3: args.append(False)
        args.extend([user, pwd])
    elif (len(args) in (2, 3, 4)) and ('@' in args[1]):
        user, host = args[1].split('@')
        args[1] = host
        if len(args) == 2: args.append(PROXY_DEFAULTS[args[0]])
        if len(args) == 3: args.append(False)
        args.append(user)

    if len(args) == 2: args.append(PROXY_DEFAULTS[args[0]])
    if len(args) > 2: args[2] = int(args[2])

    if args[P_TYPE] in PROXY_SSL_TYPES:
      names = (args[P_HOST] or '').split(',')
      args[P_HOST] = names[0]
      while len(args) <= P_CERTS:
        args.append((len(args) == P_RDNS) and True or None)
      args[P_CERTS] = (len(names) > 1) and names[1:] or names

    return args

def addproxy(dest='*', proxytype=None, addr=None, port=None, rdns=True,
                   username=None, password=None, certnames=None):
    global _proxyroutes
    route = _proxyroutes.get(dest.lower(), None)
    proxy = (proxytype, addr, port, rdns, username, password, certnames)
    if route is None:
        route = _proxyroutes.get(DEFAULT_ROUTE, [])[:]
    route.append(proxy)
    _proxyroutes[dest.lower()] = route
    if DEBUG: DEBUG('Routes are: %s' % (_proxyroutes, ))

def setproxy(dest, *args, **kwargs):
    global _proxyroutes
    dest = dest.lower()
    if args:
      _proxyroutes[dest] = []
      return addproxy(dest, *args, **kwargs)
    else:
      if dest in _proxyroutes:
        del _proxyroutes[dest.lower()]

def setdefaultcertfile(path):
    global TLS_CA_CERTS
    TLS_CA_CERTS = path

def setdefaultproxy(*args, **kwargs):
    """setdefaultproxy(proxytype, addr[, port[, rdns[, username[, password[, certnames]]]]])
    Sets a default proxy which all further socksocket objects will use,
    unless explicitly changed.
    """
    if args and args[P_TYPE] == PROXY_TYPE_DEFAULT:
        raise ValueError("Circular reference to default proxy.")
    return setproxy(DEFAULT_ROUTE, *args, **kwargs)

def adddefaultproxy(*args, **kwargs):
    if args and args[P_TYPE] == PROXY_TYPE_DEFAULT:
        raise ValueError("Circular reference to default proxy.")
    return addproxy(DEFAULT_ROUTE, *args, **kwargs)

def usesystemdefaults():
    import os

    no_proxy = ['localhost', 'localhost.localdomain', '127.0.0.1']
    no_proxy.extend(os.environ.get('NO_PROXY',
                                   os.environ.get('NO_PROXY',
                                                  '')).split(','))
    for host in no_proxy:
        setproxy(host, PROXY_TYPE_NONE)

    for var in ('ALL_PROXY', 'HTTPS_PROXY', 'http_proxy'):
        val = os.environ.get(var.lower(), os.environ.get(var, None))
        if val:
            setdefaultproxy(*parseproxy(val))
            os.environ[var] = ''
            return

def sockcreateconn(*args, **kwargs):
    _thread_locals.create_conn = args[0]
    try:
      rv = _orgcreateconn(*args, **kwargs)
      return rv
    finally:
      del(_thread_locals.create_conn)

class socksocket(socket.socket):
    """socksocket([family[, type[, proto]]]) -> socket object
    Open a SOCKS enabled socket. The parameters are the same as
    those of the standard socket init. In order for SOCKS to work,
    you must specify family=AF_INET, type=SOCK_STREAM and proto=0.
    """

    def __init__(self, family=socket.AF_INET, type=socket.SOCK_STREAM, proto=0,
                 *args, **kwargs):
        self.__family = family
        self.__type = type
        self.__proto = proto
        self.__args = args
        self.__kwargs = kwargs
        self.__sock = _orgsocket(family, self.__type, self.__proto,
                                 *self.__args, **self.__kwargs)
        self.__proxy = None
        self.__proxysockname = None
        self.__proxypeername = None
        self.__makefile_refs = 0
        self.__buffer = b''
        self.__negotiating = False
        self.__override = ['addproxy', 'setproxy',
                           'getproxysockname', 'getproxypeername',
                           'close', 'connect', 'getpeername', 'makefile',
                           'recv', 'recv_into'] #, 'send', 'sendall']

    def __getattribute__(self, name):
        if name.startswith('_socksocket__'):
          return object.__getattribute__(self, name)
        elif name in self.__override:
          return object.__getattribute__(self, name)
        else:
          return getattr(object.__getattribute__(self, "_socksocket__sock"),
                         name)

    def __setattr__(self, name, value):
        if name.startswith('_socksocket__'):
          return object.__setattr__(self, name, value)
        else:
          return setattr(object.__getattribute__(self, "_socksocket__sock"),
                         name, value)

    def __settimeout(self, timeout):
        try:
            self.__sock.settimeout(timeout)
        except:
            # Python 2.2 compatibility hacks.
            pass

    def __recvall(self, count):
        """__recvall(count) -> data
        Receive EXACTLY the number of bytes requested from the socket.
        Blocks until the required number of bytes have been received or a
        timeout occurs.
        """
        self.__sock.setblocking(1)
        self.__settimeout(DEFAULT_TIMEOUT)

        data = self.recv(count)
        while len(data) < count:
            d = self.recv(count-len(data))
            if d == '':
                raise GeneralProxyError((0, "connection closed unexpectedly"))
            data = data + d
        return data

    def close(self):
        if self.__makefile_refs < 1:
            self.__sock.close()
        else:
            self.__makefile_refs -= 1

    def makefile(self, mode='r', bufsize=-1):
        self.__makefile_refs += 1
        if PY2:
            return socket._fileobject(self, mode, bufsize, close=True)
        else:
            return socket.SocketIO(self, mode)

    def addproxy(self, proxytype=None, addr=None, port=None, rdns=True, username=None, password=None, certnames=None):
        """setproxy(proxytype, addr[, port[, rdns[, username[, password[, certnames]]]]])
        Sets the proxy to be used.
        proxytype -    The type of the proxy to be used. Three types
                are supported: PROXY_TYPE_SOCKS4 (including socks4a),
                PROXY_TYPE_SOCKS5 and PROXY_TYPE_HTTP
        addr -        The address of the server (IP or DNS).
        port -        The port of the server. Defaults to 1080 for SOCKS
                servers and 8080 for HTTP proxy servers.
        rdns -        Should DNS queries be preformed on the remote side
                (rather than the local side). The default is True.
                Note: This has no effect with SOCKS4 servers.
        username -    Username to authenticate with to the server.
                The default is no authentication.
        password -    Password to authenticate with to the server.
                Only relevant when username is also provided.
        """
        proxy = (proxytype, addr, port, rdns, username, password, certnames)
        if not self.__proxy: self.__proxy = []
        self.__proxy.append(proxy)

    def setproxy(self, *args, **kwargs):
        """setproxy(proxytype, addr[, port[, rdns[, username[, password[, certnames]]]]])
           (see addproxy)
        """
        self.__proxy = []
        self.addproxy(*args, **kwargs)

    def __negotiatesocks5(self, destaddr, destport, proxy):
        """__negotiatesocks5(self, destaddr, destport, proxy)
        Negotiates a connection through a SOCKS5 server.
        """
        # First we'll send the authentication packages we support.
        if (proxy[P_USER]!=None) and (proxy[P_PASS]!=None):
            # The username/password details were supplied to the
            # setproxy method so we support the USERNAME/PASSWORD
            # authentication (in addition to the standard none).
            self.sendall(struct.pack('BBBB', 0x05, 0x02, 0x00, 0x02))
        else:
            # No username/password were entered, therefore we
            # only support connections with no authentication.
            self.sendall(struct.pack('BBB', 0x05, 0x01, 0x00))
        # We'll receive the server's response to determine which
        # method was selected
        chosenauth = self.__recvall(2)
        if chosenauth[0:1] != chr(0x05).encode():
            self.close()
            raise GeneralProxyError((1, _generalerrors[1]))
        # Check the chosen authentication method
        if chosenauth[1:2] == chr(0x00).encode():
            # No authentication is required
            pass
        elif chosenauth[1:2] == chr(0x02).encode():
            # Okay, we need to perform a basic username/password
            # authentication.
            self.sendall(chr(0x01).encode() +
                         chr(len(proxy[P_USER])) + proxy[P_USER] +
                         chr(len(proxy[P_PASS])) + proxy[P_PASS])
            authstat = self.__recvall(2)
            if authstat[0:1] != chr(0x01).encode():
                # Bad response
                self.close()
                raise GeneralProxyError((1, _generalerrors[1]))
            if authstat[1:2] != chr(0x00).encode():
                # Authentication failed
                self.close()
                raise Socks5AuthError((3, _socks5autherrors[3]))
            # Authentication succeeded
        else:
            # Reaching here is always bad
            self.close()
            if chosenauth[1] == chr(0xFF).encode():
                raise Socks5AuthError((2, _socks5autherrors[2]))
            else:
                raise GeneralProxyError((1, _generalerrors[1]))
        # Now we can request the actual connection
        req = struct.pack('BBB', 0x05, 0x01, 0x00)
        # If the given destination address is an IP address, we'll
        # use the IPv4 address request even if remote resolving was specified.
        try:
            ipaddr = socket.inet_aton(destaddr)
            if isinstance(ipaddr, str):
                ipaddr = ipaddr.encode('latin-1')
            req = req + chr(0x01).encode() + ipaddr
        except socket.error:
            # Well it's not an IP number,  so it's probably a DNS name.
            if proxy[P_RDNS]:
                # Resolve remotely
                ipaddr = None
                req = req + (chr(0x03).encode() +
                             chr(len(destaddr)).encode() + b(destaddr))
            else:
                # Resolve locally
                ipaddr = socket.inet_aton(socket.gethostbyname(destaddr))
                if isinstance(ipaddr, str):
                    ipaddr = ipaddr.encode('UTF-8')
                req = req + chr(0x01).encode() + ipaddr
        req = req + struct.pack(">H", destport)
        self.sendall(req)
        # Get the response
        resp = self.__recvall(4)
        if resp[0:1] != chr(0x05).encode():
            self.close()
            raise GeneralProxyError((1, _generalerrors[1]))
        elif resp[1:2] != chr(0x00).encode():
            # Connection failed
            self.close()
            if ord(resp[1:2])<=8:
                raise Socks5Error((ord(resp[1:2]),
                                   _socks5errors[ord(resp[1:2])]))
            else:
                raise Socks5Error((9, _socks5errors[9]))
        # Get the bound address/port
        elif resp[3:4] == chr(0x01).encode():
            boundaddr = self.__recvall(4)
        elif resp[3:4] == chr(0x03).encode():
            resp = resp + self.recv(1)
            boundaddr = self.__recvall(ord(resp[4:5]))
        else:
            self.close()
            raise GeneralProxyError((1,_generalerrors[1]))
        boundport = struct.unpack(">H", self.__recvall(2))[0]
        self.__proxysockname = (boundaddr, boundport)
        if ipaddr != None:
            self.__proxypeername = (socket.inet_ntoa(ipaddr), destport)
        else:
            self.__proxypeername = (destaddr, destport)

    def getproxysockname(self):
        """getsockname() -> address info
        Returns the bound IP address and port number at the proxy.
        """
        return self.__proxysockname

    def getproxypeername(self):
        """getproxypeername() -> address info
        Returns the IP and port number of the proxy.
        """
        return _orgsocket.getpeername(self)

    def getpeername(self):
        """getpeername() -> address info
        Returns the IP address and port number of the destination
        machine (note: getproxypeername returns the proxy)
        """
        return self.__proxypeername

    def __negotiatesocks4(self, destaddr, destport, proxy):
        """__negotiatesocks4(self, destaddr, destport, proxy)
        Negotiates a connection through a SOCKS4 server.
        """
        # Check if the destination address provided is an IP address
        rmtrslv = False
        try:
            ipaddr = socket.inet_aton(destaddr)
        except socket.error:
            # It's a DNS name. Check where it should be resolved.
            if proxy[P_RDNS]:
                ipaddr = struct.pack("BBBB", 0x00, 0x00, 0x00, 0x01)
                rmtrslv = True
            else:
                ipaddr = socket.inet_aton(socket.gethostbyname(destaddr))
        # Construct the request packet
        req = struct.pack(">BBH", 0x04, 0x01, destport) + ipaddr
        # The username parameter is considered userid for SOCKS4
        if proxy[P_USER] != None:
            req = req + proxy[P_USER]
        req = req + chr(0x00).encode()
        # DNS name if remote resolving is required
        # NOTE: This is actually an extension to the SOCKS4 protocol
        # called SOCKS4A and may not be supported in all cases.
        if rmtrslv:
            req = req + destaddr + chr(0x00).encode()
        self.sendall(req)
        # Get the response from the server
        resp = self.__recvall(8)
        if resp[0:1] != chr(0x00).encode():
            # Bad data
            self.close()
            raise GeneralProxyError((1,_generalerrors[1]))
        if resp[1:2] != chr(0x5A).encode():
            # Server returned an error
            self.close()
            if ord(resp[1:2]) in (91, 92, 93):
                self.close()
                raise Socks4Error((ord(resp[1:2]), _socks4errors[ord(resp[1:2]) - 90]))
            else:
                raise Socks4Error((94, _socks4errors[4]))
        # Get the bound address/port
        self.__proxysockname = (socket.inet_ntoa(resp[4:]),
                                struct.unpack(">H", resp[2:4])[0])
        if rmtrslv != None:
            self.__proxypeername = (socket.inet_ntoa(ipaddr), destport)
        else:
            self.__proxypeername = (destaddr, destport)

    def __getproxyauthheader(self, proxy):
        if proxy[P_USER] and proxy[P_PASS]:
          auth = proxy[P_USER] + ":" + proxy[P_PASS]
          return "Proxy-Authorization: Basic %s\r\n" % base64.b64encode(auth)
        else:
          return b""

    def __stop_http_negotiation(self):
        buf = self.__buffer
        host, port, proxy = self.__negotiating
        self.__buffer = self.__negotiating = None
        self.__override.remove('send')
        self.__override.remove('sendall')
        return (buf, host, port, proxy)

    def recv(self, count, flags=0):
        if self.__negotiating:
            # If the calling code tries to read before negotiating is done,
            # assume this is not HTTP, bail and attempt HTTP CONNECT.
            if DEBUG: DEBUG("*** Not HTTP, failing back to HTTP CONNECT.")
            buf, host, port, proxy = self.__stop_http_negotiation()
            self.__negotiatehttpconnect(host, port, proxy)
            self.__sock.sendall(buf)
        while True:
            try:
                return self.__sock.recv(count, flags)
            except SSL.SysCallError:
                return ''
            except SSL.WantReadError:
                pass

    def recv_into(self, buf, nbytes=0, flags=0):
        if self.__negotiating:
            # If the calling code tries to read before negotiating is done,
            # assume this is not HTTP, bail and attempt HTTP CONNECT.
            if DEBUG: DEBUG("*** Not HTTP, failing back to HTTP CONNECT.")
            buf, host, port, proxy = self.__stop_http_negotiation()
            self.__negotiatehttpconnect(host, port, proxy)
            self.__sock.sendall(buf)
        while True:
            try:
                return self.__sock.recv_into(buf, nbytes, flags)
            except SSL.SysCallError:
                return 0
            except SSL.WantReadError:
                pass

    def send(self, *args, **kwargs):
        if self.__negotiating:
            self.__buffer += args[0]
            self.__negotiatehttpproxy()
        else:
            return self.__sock.send(*args, **kwargs)

    def sendall(self, *args, **kwargs):
        if self.__negotiating:
            self.__buffer += args[0]
            self.__negotiatehttpproxy()
        else:
            return self.__sock.sendall(*args, **kwargs)

    def __negotiatehttp(self, destaddr, destport, proxy):
        """__negotiatehttpproxy(self, destaddr, destport, proxy)
        Negotiates a connection through an HTTP proxy server.
        """
        if destport in (21, 22, 23, 25, 109, 110, 143, 220, 443, 993, 995):
            # Go straight to HTTP CONNECT for anything related to e-mail,
            # SSH, telnet, FTP, SSL, ...
            self.__negotiatehttpconnect(destaddr, destport, proxy)
        else:
            if DEBUG: DEBUG('*** Transparent HTTP proxy mode...')
            self.__negotiating = (destaddr, destport, proxy)
            self.__override.extend(['send', 'sendall'])

    def __negotiatehttpproxy(self):
        """__negotiatehttp(self, destaddr, destport, proxy)
        Negotiates an HTTP request through an HTTP proxy server.
        """
        buf = self.__buffer
        host, port, proxy = self.__negotiating

        # If our buffer is tiny, wait for data.
        if len(buf) <= 3: return

        # If not HTTP, fall back to HTTP CONNECT.
        if buf[0:3].lower() not in (b'get', b'pos', b'hea',
                                    b'put', b'del', b'opt', b'pro'):
            if DEBUG: DEBUG("*** Not HTTP, failing back to HTTP CONNECT.")
            self.__stop_http_negotiation()
            self.__negotiatehttpconnect(host, port, proxy)
            self.__sock.sendall(buf)
            return

        # Have we got the end of the headers?
        if buf.find('\r\n\r\n'.encode()) != -1:
            CRLF = b'\r\n'
        elif buf.find('\n\n'.encode()) != -1:
            CRLF = b'\n'
        else:
            # Nope
            return

        # Remove our send/sendall hooks.
        self.__stop_http_negotiation()

        # Format the proxy request.
        host += ':%d' % port
        headers_socks = buf.split(CRLF)
        for hdr in headers_socks:
            if hdr.lower().startswith(b'host: '): host = hdr[6:]
        req = headers_socks[0].split(b' ', 1)
        #headers[0] = f'{req[0].decode("UTF-8")} http://{host.decode("UTF-8")}{req[1].decode("UTF-8")}'.encode('UTF-8')
        headers_raw = req[0].decode("UTF-8") + ' http://' + host.decode("UTF-8") + req[1].decode("UTF-8")
        headers_socks[0] = headers_raw.encode('UTF-8')
        headers_socks[1] = self.__getproxyauthheader(proxy) + headers_socks[1]

        # Send it!
        if DEBUG: DEBUG("*** Proxy request:\n%s***" % CRLF.join(headers_socks))
        self.__sock.sendall(CRLF.join(headers_socks))

    def __negotiatehttpconnect(self, destaddr, destport, proxy):
        """__negotiatehttp(self, destaddr, destport, proxy)
        Negotiates an HTTP CONNECT through an HTTP proxy server.
        """
        # If we need to resolve locally, we do this now
        if not proxy[P_RDNS]:
            addr = socket.gethostbyname(destaddr)
        else:
            addr = destaddr
        self.__sock.sendall(("CONNECT "
                             + addr + ":" + str(destport) + " HTTP/1.1\r\n"
                             + self.__getproxyauthheader(proxy).decode('UTF-8')
                             + "Host: " + destaddr + "\r\n\r\n"
                             ).encode())
        # We read the response until we get "\r\n\r\n" or "\n\n"
        resp = self.__recvall(1)
        while (resp.find("\r\n\r\n".encode()) == -1 and
               resp.find("\n\n".encode()) == -1):
            resp = resp + self.__recvall(1)
        # We just need the first line to check if the connection
        # was successful
        statusline = resp.splitlines()[0].split(" ".encode(), 2)
        if statusline[0] not in ("HTTP/1.0".encode(), "HTTP/1.1".encode()):
            self.close()
            raise GeneralProxyError((1, _generalerrors[1]))
        try:
            statuscode = int(statusline[1])
        except ValueError:
            self.close()
            raise GeneralProxyError((1, _generalerrors[1]))
        if statuscode != 200:
            self.close()
            raise HTTPError((statuscode, statusline[2]))
        self.__proxysockname = ("0.0.0.0", 0)
        self.__proxypeername = (addr, destport)

    def __get_ca_certs(self):
        return TLS_CA_CERTS

    def __negotiatessl(self, destaddr, destport, proxy,
                       weak=False, anonymous=False):
        """__negotiatessl(self, destaddr, destport, proxy)
        Negotiates an SSL session.
        """
        want_hosts = ca_certs = self_cert = None
        if not weak and not anonymous:
            # This is normal, secure mode.
            self_cert = proxy[P_USER] or None
            ca_certs  = proxy[P_CACERTS] or self.__get_ca_certs() or None
            want_hosts = proxy[P_CERTS] or [proxy[P_HOST]]

        try:
            ctx = MakeBestEffortSSLContext(weak=weak, anonymous=anonymous)
            if self_cert:
                ctx.use_certificate_chain_file(self_cert)
                ctx.use_privatekey_file(self_cert)
            if ca_certs and want_hosts:
                ctx.load_verify_locations(ca_certs)

            self.__sock.setblocking(1)
            self.__sock = SSL_Connect(ctx, self.__sock,
                                      connected=True, verify_names=want_hosts)
        except:
            if DEBUG: DEBUG('*** SSL problem: %s/%s/%s' % (sys.exc_info(),
                                                           self.__sock,
                                                           want_hosts))
            raise

        self.__encrypted = True
        if DEBUG: DEBUG('*** Wrapped %s:%s in %s' % (destaddr, destport,
                                                     self.__sock))

    def __default_route(self, dest):
        route = _proxyroutes.get(str(dest).lower(), [])[:]
        if not route or route[0][P_TYPE] == PROXY_TYPE_DEFAULT:
            route[0:1] = _proxyroutes.get(DEFAULT_ROUTE, [])
        while route and route[0][P_TYPE] == PROXY_TYPE_DEFAULT:
            route.pop(0)
        return route

    def __do_connect(self, addrspec):
      if ':' in addrspec[0]:
        self.__sock = _orgsocket(socket.AF_INET6, self.__type, self.__proto,
                                 *self.__args, **self.__kwargs)
        self.__settimeout(DEFAULT_TIMEOUT)
        return self.__sock.connect(addrspec)
      else:
        try:
          self.__sock = _orgsocket(socket.AF_INET, self.__type, self.__proto,
                                   *self.__args, **self.__kwargs)
          self.__settimeout(DEFAULT_TIMEOUT)
          return self.__sock.connect(addrspec)
        except socket.gaierror:
          self.__sock = _orgsocket(socket.AF_INET6, self.__type, self.__proto,
                                   *self.__args, **self.__kwargs)
          self.__settimeout(DEFAULT_TIMEOUT)
          return self.__sock.connect(addrspec)

    def connect(self, destpair):
        """connect(self, despair)
        Connects to the specified destination through a chain of proxies.
        destpar - A tuple of the IP/DNS address and the port number.
        (identical to socket's connect).
        To select the proxy servers use setproxy() and chainproxy().
        """
        if DEBUG: DEBUG('*** Connect: %s / %s' % (destpair, self.__proxy))
        destpair = getattr(_thread_locals, 'create_conn', destpair)

        # Do a minimal input check first
        if ((not type(destpair) in (list, tuple)) or
            (len(destpair) < 2) or (type(destpair[0]) != type('')) or
            (type(destpair[1]) != int)):
            raise GeneralProxyError((5, _generalerrors[5]))

        if self.__proxy:
            proxy_chain = self.__proxy
            default_dest = destpair[0]
        else:
            proxy_chain = self.__default_route(destpair[0])
            default_dest = DEFAULT_ROUTE

        for proxy in proxy_chain:
            if (proxy[P_TYPE] or PROXY_TYPE_NONE) not in PROXY_DEFAULTS:
                raise GeneralProxyError((4, _generalerrors[4]))

        chain = proxy_chain[:]
        chain.append([PROXY_TYPE_NONE, destpair[0], destpair[1]])
        if DEBUG: DEBUG('*** Chain: %s' % (chain, ))

        first = True
        result = None
        while chain:
            proxy = chain.pop(0)

            if proxy[P_TYPE] == PROXY_TYPE_DEFAULT:
                chain[0:0] = self.__default_route(default_dest)
                if DEBUG: DEBUG('*** Chain: %s' % chain)
                continue

            if proxy[P_PORT] != None:
                portnum = proxy[P_PORT]
            else:
                portnum = PROXY_DEFAULTS[proxy[P_TYPE] or PROXY_TYPE_NONE]

            if first and proxy[P_HOST]:
                if DEBUG: DEBUG('*** Connect: %s:%s' % (proxy[P_HOST], portnum))
                result = self.__do_connect((proxy[P_HOST], portnum))

            if chain:
                nexthop = (chain[0][P_HOST] or '', int(chain[0][P_PORT] or 0))

                if proxy[P_TYPE] in PROXY_SSL_TYPES:
                    if DEBUG: DEBUG('*** TLS/SSL Setup: %s' % (nexthop, ))
                    self.__negotiatessl(nexthop[0], nexthop[1], proxy,
                      weak=(proxy[P_TYPE] == PROXY_TYPE_SSL_WEAK),
                      anonymous=(proxy[P_TYPE] == PROXY_TYPE_SSL_ANON))

                if proxy[P_TYPE] in PROXY_HTTPC_TYPES:
                    if DEBUG: DEBUG('*** HTTP CONNECT: %s' % (nexthop, ))
                    self.__negotiatehttpconnect(nexthop[0], nexthop[1], proxy)

                elif proxy[P_TYPE] in PROXY_HTTP_TYPES:
                    if len(chain) > 1:
                        # Chaining requires HTTP CONNECT.
                        if DEBUG: DEBUG('*** HTTP CONNECT: %s' % (nexthop, ))
                        self.__negotiatehttpconnect(nexthop[0], nexthop[1],
                                                    proxy)
                    else:
                        # If we are last in the chain, do transparent magic.
                        if DEBUG: DEBUG('*** HTTP PROXY: %s' % (nexthop, ))
                        self.__negotiatehttp(nexthop[0], nexthop[1], proxy)

                if proxy[P_TYPE] in PROXY_SOCKS5_TYPES:
                    if DEBUG: DEBUG('*** SOCKS5: %s' % (nexthop, ))
                    self.__negotiatesocks5(nexthop[0], nexthop[1], proxy)

                elif proxy[P_TYPE] == PROXY_TYPE_SOCKS4:
                    if DEBUG: DEBUG('*** SOCKS4: %s' % (nexthop, ))
                    self.__negotiatesocks4(nexthop[0], nexthop[1], proxy)

                elif proxy[P_TYPE] == PROXY_TYPE_NONE:
                    if first and nexthop[0] and nexthop[1]:
                         if DEBUG: DEBUG('*** Connect: %s:%s' % nexthop)
                         result = self.__do_connect(nexthop)
                    else:
                         raise GeneralProxyError((4, _generalerrors[4]))

            first = False

        if DEBUG: DEBUG('*** Connected! (%s)' % result)
        return result

def wrapmodule(module):
    """wrapmodule(module)
    Attempts to replace a module's socket library with a SOCKS socket.
    This will only work on modules that import socket directly into the
    namespace; most of the Python Standard Library falls into this category.
    """
    module.socket.socket = socksocket
    module.socket.create_connection = sockcreateconn
    if DEBUG: DEBUG('Wrapped: %s' % module.__name__)


## Netcat-like proxy-chaining tools follow ##

def netcat(s, i, o, keep_open=''):
    if hasattr(o, 'buffer'): o = o.buffer
    try:
        in_fileno = i.fileno()
        isel = [s, i]
        obuf, sbuf, oselo, osels = [], [], [], []
        while isel:
            in_r, out_r, err_r = select.select(isel, oselo+osels, isel, 1000)

#           print 'In:%s Out:%s Err:%s' % (in_r, out_r, err_r)
            if s in in_r:
                obuf.append(s.recv(4096))
                oselo = [o]
                if len(obuf[-1]) == 0:
                    if DEBUG: DEBUG('EOF(s, in)')
                    isel.remove(s)

            if o in out_r:
                o.write(obuf[0])
                if len(obuf) == 1:
                    if len(obuf[0]) == 0:
                        if DEBUG: DEBUG('CLOSE(o)')
                        o.close()
                        if i in isel and 'i' not in keep_open:
                            isel.remove(i)
                            i.close()
                    else:
                        o.flush()
                    obuf, oselo = [], []
                else:
                    obuf.pop(0)

            if i in in_r:
                sbuf.append(os.read(in_fileno, 4096))
                osels = [s]
                if len(sbuf[-1]) == 0:
                    if DEBUG: DEBUG('EOF(i)')
                    isel.remove(i)

            if s in out_r:
                s.send(sbuf[0])
                if len(sbuf) == 1:
                    if len(sbuf[0]) == 0:
                        if s in isel and 's' not in keep_open:
                            if DEBUG: DEBUG('CLOSE(s)')
                            isel.remove(s)
                            s.close()
                        else:
                            if DEBUG: DEBUG('SHUTDOWN(s, WR)')
                            s.shutdown(socket.SHUT_WR)
                    sbuf, osels = [], []
                else:
                    sbuf.pop(0)

        for data in sbuf: s.sendall(data)
        for data in obuf: o.write(data)

    except:
        if DEBUG: DEBUG("Disconnected: %s" % (sys.exc_info(), ))

    i.close()
    s.close()
    o.close()

def __proxy_connect_netcat(hostname, port, chain, keep_open):
    try:
        s = socksocket(socket.AF_INET, socket.SOCK_STREAM)
        for proxy in chain:
            s.addproxy(*proxy)
        s.connect((hostname, port))
    except:
        sys.stderr.write('Error: %s\n' % (sys.exc_info(), ))
        return False
    netcat(s, sys.stdin, sys.stdout, keep_open)
    return True

def __make_proxy_chain(args):
    chain = []
    for arg in args:
        chain.append(parseproxy(arg))
    return chain

def DebugPrint(text):
    print(text)
