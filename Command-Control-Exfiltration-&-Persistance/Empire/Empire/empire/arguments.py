"""
Parse arguments.
Life saver comment on separating the parser.
https://stackoverflow.com/a/30217387
"""
import argparse

parent_parser = argparse.ArgumentParser()
subparsers = parent_parser.add_subparsers(dest='subparser_name')

server_parser = subparsers.add_parser('server', help='Launch Empire Server')
client_parser = subparsers.add_parser('client', help='Launch Empire CLI')

# Client Args
client_parser.add_argument('-r', '--resource', type=str,
                           help='Run the Empire commands in the specified resource file after startup.')
client_parser.add_argument('--config', type=str, nargs=1,
                           help='Specify a config.yaml different from the config.yaml in the empire/client directory.')

# Server Args
general_group = server_parser.add_argument_group('General Options')
general_group.add_argument('--debug', nargs='?', const='1',
                           help='Debug level for output (default of 1, 2 for msg display).')
general_group.add_argument('--reset', action='store_true', help="Resets Empire's database to defaults.")
general_group.add_argument('-v', '--version', action='store_true', help='Display current Empire version.')
general_group.add_argument('--config', type=str, nargs=1,
                           help='Specify a config.yaml different from the config.yaml in the empire/server directory.')

rest_group = server_parser.add_argument_group('RESTful API Options')
rest_group.add_argument('--restip', nargs=1, help='IP to bind the Empire RESTful API on. Defaults to 0.0.0.0')
rest_group.add_argument('--restport', type=int, nargs=1, help='Port to run the Empire RESTful API on. Defaults to 1337')
rest_group.add_argument('--socketport', type=int, nargs=1, help='Port to run socketio on. Defaults to 5000')
rest_group.add_argument('--username', nargs=1,
                        help='Start the RESTful API with the specified username instead of pulling from empire.db')
rest_group.add_argument('--password', nargs=1,
                        help='Start the RESTful API with the specified password instead of pulling from empire.db')

args = parent_parser.parse_args()

if parent_parser.parse_args().subparser_name == None:
    parent_parser.print_help()
