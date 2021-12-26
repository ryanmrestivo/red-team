# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from spnego._sspi_raw.security cimport (
    CredHandle,
    CtxtHandle,
    PSecBuffer,
    PSecBufferDesc,
    SecBuffer as NativeSecBuffer,
    SecBufferDesc as NativeSecBufferDesc,
    SEC_WINNT_AUTH_IDENTITY_W,
)

from spnego._sspi_raw.text cimport (
    WideChar,
)


cdef class Credential:

    cdef CredHandle handle
    cdef readonly unsigned long long expiry


cdef class SecurityContext:

    cdef CtxtHandle handle
    cdef readonly unsigned long context_attr
    cdef readonly unsigned long long expiry
    cdef unsigned long init


cdef class SecBufferDesc:
    cdef NativeSecBufferDesc _c_value
    cdef list _buffers

    cdef PSecBufferDesc __c_value__(SecBufferDesc self)


cdef class SecBuffer:
    cdef PSecBuffer c_value
    cdef object sys_alloc
    cdef object _is_owner
    cdef void *_p_buffer

    cdef replace_ptr(SecBuffer self, PSecBuffer ptr)


cdef class _AuthIdentityBase:

    cdef void *__c_value__(_AuthIdentityBase self)


cdef class WinNTAuthIdentity(_AuthIdentityBase):

    cdef WideChar _username
    cdef WideChar _domain
    cdef WideChar _password
    cdef SEC_WINNT_AUTH_IDENTITY_W c_value

    cdef void *__c_value__(WinNTAuthIdentity self)
