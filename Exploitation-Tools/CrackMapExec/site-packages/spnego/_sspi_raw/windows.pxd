# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from libc.stddef cimport wchar_t


cdef extern from "Windows.h":
    # Types
    ctypedef long LONG
    ctypedef unsigned long UINT
    ctypedef unsigned long DWORD
    ctypedef int BOOL

    ctypedef wchar_t WCHAR
    ctypedef WCHAR *LPWSTR
    ctypedef const WCHAR *LPCWSTR
    ctypedef LPWSTR LPTSTR;
    ctypedef LPCWSTR LPCTSTR

    ctypedef void *PVOID
    ctypedef PVOID HANDLE

    # Defs
    cdef UINT CP_UTF8

    # Structs

    # Functions
    DWORD GetLastError()

    int MultiByteToWideChar(
        UINT CodePage,
        DWORD dwFlags,
        char *lpMultiByteStr,
        int cbMultiByte,
        LPWSTR lpWideCharStr,
        int cchWideChar
    )
