"""
Event handling system
Every "major" event in Empire (loosely defined as everything you'd want to
go into a report) is logged to the database. This file contains functions
which help manage those events - logging them, fetching them, etc.
"""

import json

from pydispatch import dispatcher
from empire.server.database.base import Session
from empire.server.database import models


# from empire.server.common import db # used in the disabled TODO below

################################################################################
# Helper functions for logging common events
################################################################################

def agent_rename(old_name, new_name):
    """
    Helper function for reporting agent name changes.

    old_name - agent's old name
    new_name - what the agent is being renamed to
    """
    # make sure to include new_name in there so it will persist if the agent
    # is renamed again - that way we can still trace the trail back if needed
    message = "[*] Agent {} has been renamed to {}".format(old_name, new_name)
    signal = json.dumps({
        'print': False,
        'message': message,
        'old_name': old_name,
        'new_name': new_name,
        'event_type': 'rename'
    })
    # signal twice, once for each name (that way, if you search by sender,
    # the last thing in the old agent and the first thing in the new is that
    # it has been renamed)
    dispatcher.send(signal, sender="agents/{}".format(old_name))
    dispatcher.send(signal, sender="agents/{}".format(new_name))

    # TODO rename all events left over using agent's old name?


def log_event(name, event_type, message, task_id=None):
    """
    Log arbitrary events

    name       - the sender string from the dispatched event
    event_type - the category of the event - agent_result, agent_task,
                 agent_rename, etc. Ideally a succinct description of what the
                 event actually is.
    message    - the body of the event, WHICH MUST BE JSON, describing any
                 pertinent details of the event
    task_id    - the ID of the task this event is in relation to. Enables quick
                 queries of an agent's task and its result together.
    """
    Session().add(models.Reporting(name=name,
                                   event_type=event_type,
                                   message=message,
                                   taskID=task_id))
    Session().commit()
