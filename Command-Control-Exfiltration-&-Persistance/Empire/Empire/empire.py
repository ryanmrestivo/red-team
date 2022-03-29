#! /usr/bin/env python3

import empire.arguments as arguments
import sys


if __name__ == '__main__':
    args = arguments.args

    if args.subparser_name == 'server':
        import empire.server.server as server
        server.run(args)

    elif args.subparser_name == 'client':
        import empire.client.client as client
        client.start()

    sys.exit(0)
