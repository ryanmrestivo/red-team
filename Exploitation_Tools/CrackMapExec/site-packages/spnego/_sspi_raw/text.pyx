# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from libc.stdlib cimport (
    free,
    malloc,
)

from spnego._sspi_raw.windows cimport (
    CP_UTF8,
    LPWSTR,
    MultiByteToWideChar,
    WCHAR,
    wchar_t
)


cdef extern from "ctype.h":
  int wcslen(wchar_t*)


cdef extern from "Python.h":
    PyUnicode_FromWideChar(const wchar_t *w, Py_ssize_t size)


cdef class WideChar:

    def __cinit__(WideChar self, size_t length):
        self.length = length
        self.buffer = NULL

        if length:
            self.buffer = <LPWSTR>malloc(length * sizeof(WCHAR))
            if not self.buffer:
                raise MemoryError("Cannot malloc for WideChar")

    def __len__(WideChar self):
        return self.length

    def __dealloc__(WideChar self):
        if self.buffer != NULL:
            free(self.buffer)

    def to_text(WideChar self, size_t length=0):
        if not length and self.length == 0:
            return u""

        # Subtract from self.length to remove the null char that LPWSTR points to.
        return u16_to_text(self.buffer, length if length else self.length - 1)

    @staticmethod
    def from_text(unicode text):
        if not text:
            return WideChar(0)

        b_text = text.encode('utf-8', 'strict')

        # Get the expected length of the text as a wide_char array and allocate it
        length = MultiByteToWideChar(CP_UTF8, 0, b_text, -1, NULL, 0)

        # Create the new WideChar object and set the text to the newly allocated buffer.
        wide_char = WideChar(length)
        MultiByteToWideChar(CP_UTF8, 0, b_text, -1, wide_char.buffer, length)
        return wide_char


cdef unicode u16_to_text(LPWSTR s, size_t length):
    # TODO: pass length straight in when Python 2.7 is dropped.
    if length == -1:
        length = wcslen(s)

    return PyUnicode_FromWideChar(s, length)
