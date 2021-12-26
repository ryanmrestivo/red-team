# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type  # noqa (fixes E402 for the imports below)

import json
import logging
import logging.config
import os

from spnego._context import (
    ContextReq,
)

from spnego.auth import (
    client,
    server,
)

from spnego.exceptions import (
    NegotiateOptions,
)


try:
    from logging import NullHandler
except ImportError:  # pragma: no cover
    class NullHandler(logging.Handler):
        def emit(self, record):
            pass


def _setup_logging(logger):
    log_path = os.environ.get('PYSPNEGO_LOG_CFG', None)

    if log_path is not None and os.path.exists(log_path):  # pragma: no cover
        # log log config from JSON file
        with open(log_path, 'rt') as f:
            config = json.load(f)

        logging.config.dictConfig(config)
    else:
        # no logging was provided
        logger.addHandler(NullHandler())


logger = logging.getLogger(__name__)
_setup_logging(logger)
