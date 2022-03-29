# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type  # noqa (fixes E402 for the imports below)

import collections

from spnego._compat import (
    IntFlag,
)


class BufferType(IntFlag):
    """Buffer types to use for an IOVBuffer type.

    These are the IOVBuffer type flags that can be set for an IOVBuffer. The keys are a generified name for the
    respective SSPI and GSSAPI flags.
    """
    empty = 0  # SECBUFFER_EMPTY | GSS_IOV_BUFFER_TYPE_EMPTY
    data = 1  # SECBUFFER_DATA | GSS_IOV_BUFFER_TYPE_DATA
    header = 2  # SECBUFFER_TOKEN | GSS_IOV_BUFFER_TYPE_HEADER
    pkg_params = 3  # SECBUFFER_PKG_PARAMS | GSS_IOV_BUFFER_TYPE_MECH_PARAMS
    trailer = 7  # SECBUFFER_STREAM_HEADER | GSS_IOV_BUFFER_TYPE_TRAILER
    padding = 9  # SECBUFFER_PADDING | GSS_IOV_BUFFER_TYPE_PADDING
    stream = 10  # SECBUFFER_STREAM | GSS_IOV_BUFFER_TYPE_STREAM
    sign_only = 11  # SECBUFFER_MECHLIST | GSS_IOV_BUFFER_TYPE_SIGN_ONLY
    mic_token = 12  # SECBUFFER_MECHLIST_SIGNATURE | GSS_IOV_BUFFER_TYPE_MIC_TOKEN


IOVBuffer = collections.namedtuple('IOVBuffer', ['type', 'data'])
"""A buffer to pass as a list to :meth:`wrap_iov()`.

Defines the buffer inside a list that is passed to :meth:`wrap_iov()`. A list of these buffers are also returned in the
`IOVUnwrapResult` under the `buffers` attribute.

On SSPI only a buffer of the type `header`, `trailer`, or `padding` can be auto allocated. On GSSAPI all buffers can be
auto allocated when `data=True` but the behaviour behind this is dependent on the mech it is run for.

Attributes:
    type (BufferType): The type of the IOV buffer.
    data (Union[bytes, int, bool]): On the output from the `*_iov` functions this is the bytes buffer or `None` if the
        buffer wasn't set. When used as an input to the `*_iov` functions this can be the buffer bytes, the length of
        buffer to allocate or a bool to state whether the buffer is auto allocated or not.
"""
