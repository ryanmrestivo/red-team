from datetime import datetime, timezone


def is_stale(lastseen: datetime, delay: int, jitter: float):
    """
    Convenience function for calculating staleness
    """
    interval_max = (delay + delay * jitter) + 30
    diff = getutcnow() - lastseen
    stale = diff.total_seconds() > interval_max
    return stale


def getutcnow():
    return datetime.now(timezone.utc)
