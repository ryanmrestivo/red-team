import functools


# Credit to SilentTrinity on these decorators.
# https://github.com/byt3bl33d3r/SILENTTRINITY/blob/master/silenttrinity/core/client/utils.py
def command(func):
    func._command = True

    @functools.wraps(func)
    def wrap(*args, **kwargs):
        return func(*args, **kwargs)

    return wrap


def register_cli_commands(cls):
    cls._cmd_registry = []
    for methodname in dir(cls):
        method = getattr(cls, methodname)
        if hasattr(method, '_command'):
            cls._cmd_registry.append(methodname)
    return cls
