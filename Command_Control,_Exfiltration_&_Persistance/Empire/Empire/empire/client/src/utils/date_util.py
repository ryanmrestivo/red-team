import humanize
from datetime import datetime, timezone


def humanize_datetime(iso_string: str = None):
    """
    From the iso-8601 formatted timestamp, Get a string representing the local time to the user
    and a time delta like '2020-12-24 15:28:44 MST (28 seconds ago)'
    :param iso_string: ISO-8601 formatted timestamp
    :return: humanized string
    """
    if iso_string is None:
        return ''

    parsed = datetime.fromisoformat(iso_string)
    local_str = parsed.astimezone().strftime('%Y-%m-%d %H:%M:%S %Z')

    return f"{local_str} ({humanize.naturaltime(datetime.now(timezone.utc) - parsed)})"

def get_utc_now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
