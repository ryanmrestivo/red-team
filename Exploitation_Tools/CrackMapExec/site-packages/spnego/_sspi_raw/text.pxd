# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from spnego._sspi_raw.windows cimport (
    LPWSTR,
)


cdef class WideChar:
    cdef LPWSTR buffer
    cdef int length


cdef unicode u16_to_text(LPWSTR s, size_t length)
