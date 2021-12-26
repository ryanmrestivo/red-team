import base64

def bz2_pack(source):
    """
    Returns `source` as bzip2-compressed Python script
    """
    import bz2
    compressed = base64.b64encode(bz2.compress(
        source.encode('utf-8'))).decode('utf-8')
    return f'import bz2,base64;exec(bz2.decompress(base64.b64decode("{compressed}")))'

def gz_pack(source):
    """
    Returns `source` as gzip-compressed Python script
    """
    import zlib
    compressed = base64.b64encode(zlib.compress(source.encode('utf-8'))).decode('utf-8')
    return f'import zlib,base64;exec(zlib.decompress(base64.b64decode("{compressed}")))'

def lzma_pack(source):
    """
    Returns `source` as lzma-compressed Python script
    """
    import lzma
    compressed = base64.b64encode(lzma.compress(source.encode('utf-8'))).decode('utf-8')
    return f'import lzma,base64;exec(lzma.decompress(base64.b64decode("{compressed}")))'
