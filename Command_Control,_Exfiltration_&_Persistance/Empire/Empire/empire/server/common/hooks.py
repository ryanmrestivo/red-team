from empire.server.common import helpers
from typing import Callable, Dict


class Hooks(object):
    """
    Hooks are currently a *Beta feature*. The methods, event names, and callback arguments are subject to change until
    it is not a beta feature.

    Add a hook to an event to do some task when an event happens.
    Potential future addition: Filters. Add a filter to an event to do some synchronous modification to the data.
    """
    # This event is triggered after the tasking is written to the database.
    # Its arguments are (tasking: models.Tasking)
    AFTER_TASKING_HOOK = 'after_tasking_hook'

    # This event is triggered after the tasking results are received but before they are written to the database.
    # Its arguments are (tasking: models.Tasking) where tasking is the db record.
    BEFORE_TASKING_RESULT_HOOK = 'before_tasking_result_hook'

    BEFORE_TASKING_RESULT_FILTER = 'before_tasking_result_filter'

    # This event is triggered after the tasking results are received and after they are written to the database.
    # Its arguments are (tasking: models.Tasking) where tasking is the db record.
    AFTER_TASKING_RESULT_HOOK = 'after_tasking_result_hook'

    # This event is triggered after the agent has checked in and a record written to the database.
    # It has one argument (agent: models.Agent)
    AFTER_AGENT_CHECKIN_HOOK = 'after_agent_checkin_hook'

    def __init__(self):
        self.hooks: Dict[str, Dict[str, Callable]] = {}
        self.filters: Dict[str, Dict[str, Callable]] = {}

    def register_hook(self, event: str, name: str, hook: Callable):
        """
        Register a hook for a hook type.
        """
        if event not in self.hooks:
            self.hooks[event] = {}
        self.hooks[event][name] = hook
    
    def register_filter(self, event: str, name: str, filter: Callable):
        """
        Register a filter for a hook type.
        """
        if event not in self.filters:
            self.filters[event] = {}
        self.filters[event][name] = filter

    def unregister_hook(self, name: str, event: str = None):
        """
        Unregister a hook.
        """
        if event is None:
            for event in self.hooks:
                self.hooks[event].pop(name)
            return
        if name in self.hooks.get(event, {}):
            self.hooks[event].pop(name)
    
    def unregister_filter(self, name: str, event: str = None):
        """
        Unregister a filter.
        """
        if event is None:
            for event in self.filters:
                self.filters[event].pop(name)
            return
        if name in self.filters.get(event, {}):
            self.filters[event].pop(name)

    def run_hooks(self, event: str, *args):
        """
        Run all hooks for a hook type.
        This could be updated to run each hook async.
        """
        if event not in self.hooks:
            return
        for hook in self.hooks.get(event, {}).values():
            try:
                hook(*args)
            except Exception as e:
                print(helpers.color(f'[!] Hook {hook} failed: {e}'))

    def run_filters(self, event: str, *args):
        """
        Run all the filters for a hook in sequence.
        The output of each filter is passed into the next filter.
        """
        if event not in self.filters:
            return
        for filter in self.filters.get(event, {}).values():
            if not isinstance(args, tuple):
                args = (args,)
            try:
                args = filter(*args)
            except Exception as e:
                print(helpers.color(f'[!] Filter {filter} failed: {e}'))
        return args


hooks = Hooks()
