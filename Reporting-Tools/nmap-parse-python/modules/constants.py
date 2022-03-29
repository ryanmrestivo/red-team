from colorama import Fore

PROTOCOLS = ['tcp','udp']
TRUE_STRINGS = ["true", "yes", "t", "y", "on", "enabled", "1"]

OPT_SERVICE_FILTER = "service_filter"
OPT_PORT_FILTER = "port_filter"
OPT_HOST_FILTER = "host_filter"
OPT_ALIVE = "only_alive"
OPT_INCLUDE_PORTS = "include_ports"
OPT_HAVE_PORTS = "have_ports"
OPT_VERBOSE = "verbose"
OPT_RAW = "raw"

PORT_OPT_DEFAULT = "default"
PORT_OPT_TCP = "tcp"
PORT_OPT_UDP = "udp"
PORT_OPT_COMBINED = "combined"
PORT_OPTIONS = [PORT_OPT_DEFAULT, PORT_OPT_TCP, PORT_OPT_UDP, PORT_OPT_COMBINED]

TEXT_NORMAL = 0
TEXT_FRIENDLY = 1
TEXT_ERROR = 2
TEXT_SUCCESS = 3

COLOUR_ERROR = Fore.RED
COLOUR_SUCCESS = Fore.GREEN
COLOUR_RESET = Fore.RESET

EXPORT_NESSUS = 'nessus'
EXPORT_HTML = 'html'
EXPORT_PDF = 'pdf'
EXPORT_CSV = 'csv'
EXPORT_FORMATS = [EXPORT_NESSUS, EXPORT_HTML, EXPORT_PDF, EXPORT_CSV]