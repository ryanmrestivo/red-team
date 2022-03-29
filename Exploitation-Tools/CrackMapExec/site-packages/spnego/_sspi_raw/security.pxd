# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from spnego._sspi_raw.windows cimport (
    LONG,
    LPWSTR,
    PVOID,
    WCHAR
)


cdef extern from "Security.h":
    # Types
    ctypedef LONG SECURITY_STATUS
    ctypedef WCHAR SEC_WCHAR;

    # Defs
    cdef unsigned long SECBUFFER_VERSION

    cdef unsigned long SECBUFFER_EMPTY
    cdef unsigned long SECBUFFER_DATA
    cdef unsigned long SECBUFFER_TOKEN
    cdef unsigned long SECBUFFER_PKG_PARAMS
    cdef unsigned long SECBUFFER_MISSING
    cdef unsigned long SECBUFFER_EXTRA
    cdef unsigned long SECBUFFER_STREAM_TRAILER
    cdef unsigned long SECBUFFER_STREAM_HEADER
    cdef unsigned long SECBUFFER_NEGOTIATION_INFO
    cdef unsigned long SECBUFFER_PADDING
    cdef unsigned long SECBUFFER_STREAM
    cdef unsigned long SECBUFFER_MECHLIST
    cdef unsigned long SECBUFFER_MECHLIST_SIGNATURE
    cdef unsigned long SECBUFFER_TARGET
    cdef unsigned long SECBUFFER_CHANNEL_BINDINGS
    cdef unsigned long SECBUFFER_CHANGE_PASS_RESPONSE
    cdef unsigned long SECBUFFER_TARGET_HOST

    cdef unsigned long SECBUFFER_ATTRMASK
    cdef unsigned long SECBUFFER_READONLY
    cdef unsigned long SECBUFFER_READONLY_WITH_CHECKSUM
    cdef unsigned long SECBUFFER_RESERVED

    cdef unsigned long SECURITY_NATIVE_DREP
    cdef unsigned long SECURITY_NETWORK_DREP

    cdef unsigned long SECPKG_ATTR_NAMES
    cdef unsigned long SECPKG_ATTR_PACKAGE_INFO
    cdef unsigned long SECPKG_ATTR_SIZES
    cdef unsigned long SECPKG_ATTR_SESSION_KEY

    cdef unsigned long SECPKG_CRED_INBOUND
    cdef unsigned long SECPKG_CRED_OUTBOUND
    cdef unsigned long SECPKG_CRED_BOTH
    cdef unsigned long SECPKG_CRED_DEFAULT
    cdef unsigned long SECPKG_CRED_RESERVED

    cdef unsigned long ASC_REQ_DELEGATE
    cdef unsigned long ASC_REQ_MUTUAL_AUTH
    cdef unsigned long ASC_REQ_REPLAY_DETECT
    cdef unsigned long ASC_REQ_SEQUENCE_DETECT
    cdef unsigned long ASC_REQ_CONFIDENTIALITY
    cdef unsigned long ASC_REQ_USE_SESSION_KEY
    cdef unsigned long ASC_REQ_ALLOCATE_MEMORY
    cdef unsigned long ASC_REQ_USE_DCE_STYLE
    cdef unsigned long ASC_REQ_DATAGRAM
    cdef unsigned long ASC_REQ_CONNECTION
    cdef unsigned long ASC_REQ_CALL_LEVEL
    cdef unsigned long ASC_REQ_FRAGMENT_SUPPLIED
    cdef unsigned long ASC_REQ_EXTENDED_ERROR
    cdef unsigned long ASC_REQ_STREAM
    cdef unsigned long ASC_REQ_INTEGRITY
    cdef unsigned long ASC_REQ_LICENSING
    cdef unsigned long ASC_REQ_IDENTIFY
    cdef unsigned long ASC_REQ_ALLOW_NULL_SESSION
    cdef unsigned long ASC_REQ_ALLOW_NON_USER_LOGONS
    cdef unsigned long ASC_REQ_ALLOW_CONTEXT_REPLAY
    cdef unsigned long ASC_REQ_FRAGMENT_TO_FIT
    cdef unsigned long ASC_REQ_NO_TOKEN
    cdef unsigned long ASC_REQ_PROXY_BINDINGS
    cdef unsigned long ASC_REQ_ALLOW_MISSING_BINDINGS

    cdef unsigned long ASC_RET_DELEGATE
    cdef unsigned long ASC_RET_MUTUAL_AUTH
    cdef unsigned long ASC_RET_REPLAY_DETECT
    cdef unsigned long ASC_RET_SEQUENCE_DETECT
    cdef unsigned long ASC_RET_CONFIDENTIALITY
    cdef unsigned long ASC_RET_USE_SESSION_KEY
    cdef unsigned long ASC_RET_ALLOCATED_MEMORY
    cdef unsigned long ASC_RET_USED_DCE_STYLE
    cdef unsigned long ASC_RET_DATAGRAM
    cdef unsigned long ASC_RET_CONNECTION
    cdef unsigned long ASC_RET_CALL_LEVEL
    cdef unsigned long ASC_RET_THIRD_LEG_FAILED
    cdef unsigned long ASC_RET_EXTENDED_ERROR
    cdef unsigned long ASC_RET_STREAM
    cdef unsigned long ASC_RET_INTEGRITY
    cdef unsigned long ASC_RET_LICENSING
    cdef unsigned long ASC_RET_IDENTIFY
    cdef unsigned long ASC_RET_NULL_SESSION
    cdef unsigned long ASC_RET_ALLOW_NON_USER_LOGONS
    cdef unsigned long ASC_RET_ALLOW_CONTEXT_REPLAY
    cdef unsigned long ASC_RET_FRAGMENT_ONLY
    cdef unsigned long ASC_RET_NO_TOKEN
    cdef unsigned long ASC_RET_NO_ADDITIONAL_TOKEN

    cdef unsigned long ISC_REQ_DELEGATE
    cdef unsigned long ISC_REQ_MUTUAL_AUTH
    cdef unsigned long ISC_REQ_REPLAY_DETECT
    cdef unsigned long ISC_REQ_SEQUENCE_DETECT
    cdef unsigned long ISC_REQ_CONFIDENTIALITY
    cdef unsigned long ISC_REQ_USE_SESSION_KEY
    cdef unsigned long ISC_REQ_PROMPT_FOR_CREDS
    cdef unsigned long ISC_REQ_USE_SUPPLIED_CREDS
    cdef unsigned long ISC_REQ_ALLOCATE_MEMORY
    cdef unsigned long ISC_REQ_USE_DCE_STYLE
    cdef unsigned long ISC_REQ_DATAGRAM
    cdef unsigned long ISC_REQ_CONNECTION
    cdef unsigned long ISC_REQ_CALL_LEVEL
    cdef unsigned long ISC_REQ_FRAGMENT_SUPPLIED
    cdef unsigned long ISC_REQ_EXTENDED_ERROR
    cdef unsigned long ISC_REQ_STREAM
    cdef unsigned long ISC_REQ_INTEGRITY
    cdef unsigned long ISC_REQ_IDENTIFY
    cdef unsigned long ISC_REQ_NULL_SESSION
    cdef unsigned long ISC_REQ_MANUAL_CRED_VALIDATION
    cdef unsigned long ISC_REQ_RESERVED1
    cdef unsigned long ISC_REQ_FRAGMENT_TO_FIT
    cdef unsigned long ISC_REQ_FORWARD_CREDENTIALS
    cdef unsigned long ISC_REQ_NO_INTEGRITY
    cdef unsigned long ISC_REQ_USE_HTTP_STYLE
    cdef unsigned long ISC_REQ_UNVERIFIED_TARGET_NAME
    cdef unsigned long ISC_REQ_CONFIDENTIALITY_ONLY

    cdef unsigned long ISC_RET_DELEGATE
    cdef unsigned long ISC_RET_MUTUAL_AUTH
    cdef unsigned long ISC_RET_REPLAY_DETECT
    cdef unsigned long ISC_RET_SEQUENCE_DETECT
    cdef unsigned long ISC_RET_CONFIDENTIALITY
    cdef unsigned long ISC_RET_USE_SESSION_KEY
    cdef unsigned long ISC_RET_USED_COLLECTED_CREDS
    cdef unsigned long ISC_RET_USED_SUPPLIED_CREDS
    cdef unsigned long ISC_RET_ALLOCATED_MEMORY
    cdef unsigned long ISC_RET_USED_DCE_STYLE
    cdef unsigned long ISC_RET_DATAGRAM
    cdef unsigned long ISC_RET_CONNECTION
    cdef unsigned long ISC_RET_INTERMEDIATE_RETURN
    cdef unsigned long ISC_RET_CALL_LEVEL
    cdef unsigned long ISC_RET_EXTENDED_ERROR
    cdef unsigned long ISC_RET_STREAM
    cdef unsigned long ISC_RET_INTEGRITY
    cdef unsigned long ISC_RET_IDENTIFY
    cdef unsigned long ISC_RET_NULL_SESSION
    cdef unsigned long ISC_RET_MANUAL_CRED_VALIDATION
    cdef unsigned long ISC_RET_RESERVED1
    cdef unsigned long ISC_RET_FRAGMENT_ONLY
    cdef unsigned long ISC_RET_FORWARD_CREDENTIALS
    cdef unsigned long ISC_RET_USED_HTTP_STYLE
    cdef unsigned long ISC_RET_NO_ADDITIONAL_TOKEN
    cdef unsigned long ISC_RET_REAUTHENTICATION

    cdef unsigned long SEC_WINNT_AUTH_IDENTITY_ANSI
    cdef unsigned long SEC_WINNT_AUTH_IDENTITY_UNICODE

    cdef unsigned long SECQOP_WRAP_NO_ENCRYPT

    cdef SECURITY_STATUS SEC_I_COMPLETE_AND_CONTINUE
    cdef SECURITY_STATUS SEC_I_COMPLETE_NEEDED
    cdef SECURITY_STATUS SEC_I_CONTINUE_NEEDED
    cdef SECURITY_STATUS SEC_I_INCOMPLETE_CREDENTIALS
    cdef SECURITY_STATUS SEC_E_INCOMPLETE_MESSAGE
    cdef SECURITY_STATUS SEC_E_OK
    cdef SECURITY_STATUS SEC_E_INSUFFICIENT_MEMORY
    cdef SECURITY_STATUS SEC_E_INTERNAL_ERROR
    cdef SECURITY_STATUS SEC_E_INVALID_HANDLE
    cdef SECURITY_STATUS SEC_E_INVALID_TOKEN
    cdef SECURITY_STATUS SEC_E_LOGON_DENIED
    cdef SECURITY_STATUS SEC_E_NO_AUTHENTICATING_AUTHORITY
    cdef SECURITY_STATUS SEC_E_NO_CREDENTIALS
    cdef SECURITY_STATUS SEC_E_TARGET_UNKNOWN
    cdef SECURITY_STATUS SEC_E_UNSUPPORTED_FUNCTION
    cdef SECURITY_STATUS SEC_E_WRONG_PRINCIPAL
    cdef SECURITY_STATUS SEC_E_NOT_OWNER
    cdef SECURITY_STATUS SEC_E_SECPKG_NOT_FOUND
    cdef SECURITY_STATUS SEC_E_UNKNOWN_CREDENTIALS
    cdef SECURITY_STATUS SEC_E_BUFFER_TOO_SMALL
    cdef SECURITY_STATUS SEC_E_CRYPTO_SYSTEM_INVALID
    cdef SECURITY_STATUS SEC_E_MESSAGE_ALTERED
    cdef SECURITY_STATUS SEC_E_OUT_OF_SEQUENCE
    cdef SECURITY_STATUS SEC_E_QOP_NOT_SUPPORTED
    cdef SECURITY_STATUS SEC_E_CONTEXT_EXPIRED

    # Structs
    struct _SEC_WINNT_AUTH_IDENTITY_W:
        void *User;
        unsigned long UserLength;
        void *Domain;
        unsigned long DomainLength;
        void *Password;
        unsigned long PasswordLength;
        unsigned long Flags;
    ctypedef _SEC_WINNT_AUTH_IDENTITY_W SEC_WINNT_AUTH_IDENTITY_W
    ctypedef SEC_WINNT_AUTH_IDENTITY_W *PSEC_WINNT_AUTH_IDENTITY_W;

    struct _SecBuffer:
        unsigned long cbBuffer
        unsigned long BufferType
        void *pvBuffer
    ctypedef _SecBuffer SecBuffer
    ctypedef SecBuffer *PSecBuffer

    struct _SecBufferDesc:
        unsigned long ulVersion
        unsigned long cBuffers
        PSecBuffer pBuffers
    ctypedef _SecBufferDesc SecBufferDesc
    ctypedef SecBufferDesc *PSecBufferDesc

    struct _SecHandle:
        pass
    ctypedef _SecHandle SecHandle
    ctypedef SecHandle *PSecHandle

    ctypedef SecHandle CredHandle
    ctypedef PSecHandle PCredHandle

    ctypedef SecHandle CtxtHandle
    ctypedef PSecHandle PCtxtHandle

    struct _SecPkgContext_Names:
        SEC_WCHAR *sUserName;
    ctypedef _SecPkgContext_Names SecPkgContext_Names
    ctypedef SecPkgContext_Names *PSecPkgContext_Names

    struct _SecPkgContext_SessionKey:
        unsigned long SessionKeyLength;
        void *SessionKey;
    ctypedef _SecPkgContext_SessionKey SecPkgContext_SessionKey
    ctypedef SecPkgContext_SessionKey *PSecPkgContext_SessionKey

    struct _SecPkgInfoW:
        unsigned long fCapabilities
        unsigned short wVersion
        unsigned short wRPCID
        unsigned long cbMaxToken
        SEC_WCHAR *Name
        SEC_WCHAR *Comment
    ctypedef _SecPkgInfoW SecPkgInfoW
    ctypedef SecPkgInfoW *PSecPkgInfoW

    struct _SecPkgContext_PackageInfoW:
        PSecPkgInfoW PackageInfo
    ctypedef _SecPkgContext_PackageInfoW SecPkgContext_PackageInfoW
    ctypedef SecPkgContext_PackageInfoW *PSecPkgContext_PackageInfoW

    struct _SecPkgContext_Sizes:
        unsigned long cbMaxToken
        unsigned long cbMaxSignature
        unsigned long cbBlockSize
        unsigned long cbSecurityTrailer
    ctypedef _SecPkgContext_Sizes SecPkgContext_Sizes
    ctypedef SecPkgContext_Sizes *PSecPkgContext_Sizes

    ctypedef struct _SECURITY_INTEGER:
        unsigned long LowPart
        long HighPart
    ctypedef _SECURITY_INTEGER SECURITY_INTEGER
    ctypedef SECURITY_INTEGER *PSECURITY_INTEGER
    ctypedef SECURITY_INTEGER TimeStamp
    ctypedef SECURITY_INTEGER *PTimeStamp

    # Functions
    SECURITY_STATUS __stdcall AcceptSecurityContext(
        PCredHandle    phCredential,
        PCtxtHandle    phContext,
        PSecBufferDesc pInput,
        unsigned long  fContextReq,
        unsigned long  TargetDataRep,
        PCtxtHandle    phNewContext,
        PSecBufferDesc pOutput,
        unsigned long  *pfContextAttr,
        PTimeStamp     ptsExpiry
    )

    SECURITY_STATUS __stdcall AcquireCredentialsHandleW(
        LPWSTR           pPrincipal,
        LPWSTR           pPackage,
        unsigned long    fCredentialUse,
        void             *pvLogonId,
        void             *pAuthData,
        void             *pGetKeyFn,
        void             *pvGetKeyArgument,
        PCredHandle      phCredential,
        PTimeStamp       ptsExpiry
    )

    SECURITY_STATUS __stdcall CompleteAuthToken(
        PCtxtHandle    phContext,
        PSecBufferDesc pToken
    )

    SECURITY_STATUS __stdcall DecryptMessage(
        PCtxtHandle    phContext,
        PSecBufferDesc pMessage,
        unsigned long  MessageSeqNo,
        unsigned long  *pfQOP
    )

    SECURITY_STATUS __stdcall DeleteSecurityContext(
        PCtxtHandle phContext
    )

    SECURITY_STATUS __stdcall EncryptMessage(
        PCtxtHandle    phContext,
        unsigned long  fQOP,
        PSecBufferDesc pMessage,
        unsigned long  MessageSeqNo
    )

    SECURITY_STATUS __stdcall FreeContextBuffer(
        PVOID pvContextBuffer
    )

    SECURITY_STATUS __stdcall FreeCredentialsHandle(
        PCredHandle phCredential
    )

    SECURITY_STATUS __stdcall InitializeSecurityContextW(
        PCredHandle      phCredential,
        PCtxtHandle      phContext,
        LPWSTR           pTargetName,
        unsigned long    fContextReq,
        unsigned long    Reserved1,
        unsigned long    TargetDataRep,
        PSecBufferDesc   pInput,
        unsigned long    Reserved2,
        PCtxtHandle      phNewContext,
        PSecBufferDesc   pOutput,
        unsigned long    *pfContextAttr,
        PTimeStamp       ptsExpiry
    )

    SECURITY_STATUS __stdcall MakeSignature(
        PCtxtHandle    phContext,
        unsigned long  fQOP,
        PSecBufferDesc pMessage,
        unsigned long  MessageSeqNo
    )

    SECURITY_STATUS __stdcall QueryContextAttributesW(
        PCtxtHandle   phContext,
        unsigned long ulAttribute,
        void          *pBuffer
    )

    SECURITY_STATUS __stdcall VerifySignature(
        PCtxtHandle    phContext,
        PSecBufferDesc pMessage,
        unsigned long  MessageSeqNo,
        unsigned long  *pfQOP
    )
