"""

Listener handling functionality for Empire.

"""
from __future__ import absolute_import
from __future__ import print_function

import copy
import fnmatch
import hashlib
import importlib.util
import json
import os
import traceback
from builtins import object
from builtins import str

from pydispatch import dispatcher
from sqlalchemy import or_, and_
from sqlalchemy.orm.attributes import flag_modified

from empire.server.database.base import Session
from empire.server.database import models
from . import helpers


class Listeners(object):
    """
    Listener handling class.
    """

    def __init__(self, main_menu, args):

        self.mainMenu = main_menu
        self.args = args

        # loaded listener format:
        #     {"listenerModuleName": moduleInstance, ...}
        self.loadedListeners = {}

        # active listener format (these are listener modules that are actually instantiated)
        #   {"listenerName" : {moduleName: 'http', options: {setModuleOptions} }}
        self.activeListeners = {}

        self.load_listeners()
        self.start_existing_listeners()

    def load_listeners(self):
        """
        Load listeners from the install + "/listeners/*" path
        """

        rootPath = "%s/listeners/" % (self.mainMenu.installPath)
        pattern = '*.py'
        print(helpers.color("[*] Loading listeners from: %s" % (rootPath)))

        for root, dirs, files in os.walk(rootPath):
            for filename in fnmatch.filter(files, pattern):
                filePath = os.path.join(root, filename)

                # don't load up any of the templates
                if fnmatch.fnmatch(filename, '*template.py'):
                    continue

                # extract just the listener module name from the full path
                listenerName = filePath.split("/listeners/")[-1][0:-3]

                # instantiate the listener module and save it to the internal cache
                spec = importlib.util.spec_from_file_location(listenerName, filePath)
                mod = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(mod)
                listener = mod.Listener(self.mainMenu, [])

                for key, value in listener.options.items():
                    if value.get('SuggestedValues') is None:
                        value['SuggestedValues'] = []
                    if value.get('Strict') is None:
                        value['Strict'] = False

                self.loadedListeners[listenerName] = listener

    def default_listener_options(self, listener_name):
        """
        Load listeners options from the install + "/listeners/*" path
        """

        root_path = "%s/listeners/" % (self.mainMenu.installPath)
        pattern = '*.py'

        file_path = os.path.join(root_path, listener_name + '.py')

        # instantiate the listener module and save it to the internal cache
        spec = importlib.util.spec_from_file_location(listener_name, file_path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        self.loadedListeners[listener_name].options = mod.Listener(self.mainMenu, []).options

    def set_listener_option(self, listenerName, option, value):
        """
        Sets an option for the given listener module or all listener module.
        """
        for name, listenerObject in self.loadedListeners.items():
            if (listenerName.lower() == 'all' or listenerName == name) and (option in listenerObject.options):
                # parse and auto-set some host parameters
                if option == 'Host':

                    if not value.startswith('http'):
                        parts = value.split(':')
                        # if there's a current ssl cert path set, assume this is https
                        if ('CertPath' in listenerObject.options) and (
                                listenerObject.options['CertPath']['Value'] != ''):
                            protocol = 'https'
                            defaultPort = 443
                        else:
                            protocol = 'http'
                            defaultPort = 80

                    elif value.startswith('https'):
                        value = value.split('//')[1]
                        parts = value.split(':')
                        protocol = 'https'
                        defaultPort = 443

                    elif value.startswith('http'):
                        value = value.split('//')[1]
                        parts = value.split(':')
                        protocol = 'http'
                        defaultPort = 80

                    ##################################################################################################################################
                    # Added functionality to Port
                    # Unsure if this section is needed
                    if len(parts) != 1 and parts[-1].isdigit():
                        # if a port is specified with http://host:port
                        listenerObject.options['Host']['Value'] = "%s://%s" % (protocol, value)
                        if listenerObject.options['Port']['Value'] == '':
                            listenerObject.options['Port']['Value'] = parts[-1]
                    elif listenerObject.options['Port']['Value'] != '':
                        # otherwise, check if the port value was manually set
                        listenerObject.options['Host']['Value'] = "%s://%s:%s" % (
                            protocol, value, listenerObject.options['Port']['Value'])
                    else:
                        # otherwise use default port
                        listenerObject.options['Host']['Value'] = "%s://%s" % (protocol, value)
                        if listenerObject.options['Port']['Value'] == '':
                            listenerObject.options['Port']['Value'] = defaultPort
                    ###################################################################################################################################
                    return True

                elif option == 'CertPath' and value != '':
                    listenerObject.options[option]['Value'] = value
                    host = listenerObject.options['Host']['Value']
                    # if we're setting a SSL cert path, but the host is specific at http
                    if host.startswith('http:'):
                        listenerObject.options['Host']['Value'] = listenerObject.options['Host']['Value'].replace(
                            'http:', 'https:')
                    return True

                if option == 'Port':
                    listenerObject.options[option]['Value'] = value
                    # Check if Port is set and add it to host
                    parts = listenerObject.options['Host']['Value']
                    if parts.startswith('https'):
                        address = parts[8:]
                        address = ''.join(address.split(':')[0])
                        protocol = "https"
                        listenerObject.options['Host']['Value'] = "%s://%s:%s" % (
                            protocol, address, listenerObject.options['Port']['Value'])
                    elif parts.startswith('http'):
                        address = parts[7:]
                        address = ''.join(address.split(':')[0])
                        protocol = "http"
                        listenerObject.options['Host']['Value'] = "%s://%s:%s" % (
                            protocol, address, listenerObject.options['Port']['Value'])
                    return True

                elif option == 'StagingKey':
                    # if the staging key isn't 32 characters, assume we're md5 hashing it
                    value = str(value).strip()
                    if len(value) != 32:
                        stagingKeyHash = hashlib.md5(value.encode('UTF-8')).hexdigest()
                        print(helpers.color(
                            '[!] Warning: staging key not 32 characters, using hash of staging key instead: %s' % (
                                stagingKeyHash)))
                        listenerObject.options[option]['Value'] = stagingKeyHash
                    else:
                        listenerObject.options[option]['Value'] = str(value)
                    return True

                elif option in listenerObject.options:
                    if listenerObject.options.get(option, {}).get('Strict', False) and \
                            option not in listenerObject.options.get(option, {}).get('SuggestedValues', []):
                        return False
                    listenerObject.options[option]['Value'] = value
                    return True

                else:
                    print(helpers.color('[!] Error: invalid option name'))
                    return False

    def start_listener(self, module_name, listener_object):
        """
        Takes a listener module object, starts the listener, adds the listener to the database, and
        adds the listener to the current listener cache.
        """

        category = listener_object.info['Category']
        name = listener_object.options['Name']['Value']
        name_base = name

        if isinstance(name, bytes):
            name = name.decode('UTF-8')

        if not listener_object.validate_options():
            return

        i = 1
        while name in list(self.activeListeners.keys()):
            name = "%s%s" % (name_base, i)

        listener_object.options['Name']['Value'] = name

        try:
            print(helpers.color("[*] Starting listener '%s'" % (name)))
            success = listener_object.start(name=name)

            if success:
                listener_options = copy.deepcopy(listener_object.options)
                self.activeListeners[name] = {'moduleName': module_name, 'options': listener_options}

                Session().add(models.Listener(name=name,
                                              module=module_name,
                                              listener_category=category,
                                              enabled=True,
                                              options=listener_options
                                              ))
                Session().commit()

                # dispatch this event
                message = "[+] Listener successfully started!"
                signal = json.dumps({
                    'print': True,
                    'message': message,
                    'listener_options': listener_options
                })
                dispatcher.send(signal, sender="listeners/{}/{}".format(module_name, name))
                self.activeListeners[name]['name'] = name

                # TODO: listeners should not have their default options rewritten in memory after generation
                if module_name == 'redirector':
                    self.default_listener_options(module_name)

                if self.mainMenu.socketio:
                    self.mainMenu.socketio.emit('listeners/new', self.get_listener_for_socket(name), broadcast=True)
            else:
                print(helpers.color('[!] Listener failed to start!'))

        except Exception as e:
            if name in self.activeListeners:
                del self.activeListeners[name]
            print(helpers.color("[!] Error starting listener: %s" % (e)))

    def get_listener_for_socket(self, name):
        listener = Session().query(models.Listener).filter(models.Listener.name == name).first()

        return {'ID': listener.id, 'name': listener.name, 'module': listener.module,
                'listener_type': listener.listener_type,
                'listener_category': listener.listener_category, 'options': listener.options,
                'created_at': listener.created_at}

    def start_existing_listeners(self):
        """
        Startup any listeners that are currently in the database.
        """
        listeners = Session().query(models.Listener).filter(models.Listener.enabled == True).all()

        for listener in listeners:
            listener_name = listener.name
            module_name = listener.module
            name_base = listener_name
            options = listener.options

            i = 1
            while listener_name in list(self.activeListeners.keys()):
                listener_name = "%s%s" % (name_base, i)

            try:
                listener_module = self.loadedListeners[module_name]

                if module_name == 'redirector':
                    #todo: fix redirector listeners when empire is resetarted
                    print(helpers.color("[!] Redirector listeners may not work when Empire is restarted."))
                    #listener_module.options.update(options)
                    success = True
                else:
                    for option, value in options.items():
                        listener_module.options[option]['Value'] = value['Value']
                    success = listener_module.start(name=listener_name)

                print(helpers.color("[*] Starting listener '%s'" % listener_name))

                if success:
                    listener_options = copy.deepcopy(listener_module.options)
                    self.activeListeners[listener_name] = {'moduleName': module_name, 'options': listener_options}
                    # dispatch this event
                    message = "[+] Listener successfully started!"
                    signal = json.dumps({
                        'print': True,
                        'message': message,
                        'listener_options': listener_options
                    })
                    dispatcher.send(signal, sender="listeners/{}/{}".format(module_name, listener_name))
                else:
                    print(helpers.color('[!] Listener failed to start!'))

            except Exception as e:
                if listener_name in self.activeListeners:
                    del self.activeListeners[listener_name]
                print(helpers.color("[!] Error starting listener: %s" % e))

    def enable_listener(self, listener_name):
        """
        Starts an existing listener and sets it to enabled
        """
        if listener_name in list(self.activeListeners.keys()):
            print(helpers.color("[!] Listener already running!"))
            return False

        result = Session().query(models.Listener).filter(models.Listener.name == listener_name).first()

        if not result:
            print(helpers.color("[!] Listener %s doesn't exist!" % listener_name))
            return False
        module_name = result['module']
        options = result['options']

        try:
            listener_module = self.loadedListeners[module_name]

            for option, value in options.items():
                listener_module.options[option]['Value'] = value['Value']

            print(helpers.color("[*] Starting listener '%s'" % listener_name))
            if module_name == 'redirector':
                success = True
            else:
                success = listener_module.start(name=listener_name)

            if success:
                print(helpers.color('[+] Listener successfully started!'))
                listener_options = copy.deepcopy(listener_module.options)
                self.activeListeners[listener_name] = {'moduleName': module_name, 'options': listener_options}

                listener = Session().query(models.Listener).filter(
                    and_(models.Listener.name == listener_name, models.Listener.module != 'redirector')).first()
                listener.enabled = True
                Session().commit()
            else:
                print(helpers.color('[!] Listener failed to start!'))
        except Exception as e:
            traceback.print_exc()
            if listener_name in self.activeListeners:
                del self.activeListeners[listener_name]
            print(helpers.color("[!] Error starting listener: %s" % e))

    def kill_listener(self, listener_name):
        """
        Shut down the server associated with a listenerName and delete the
        listener from the database.

        To kill all listeners, use listenerName == 'all'
        """

        if listener_name.lower() == 'all':
            listener_names = list(self.activeListeners.keys())
        else:
            listener_names = [listener_name]

        for listener_name in listener_names:
            if listener_name not in self.activeListeners:
                print(helpers.color("[!] Listener '%s' not active!" % (listener_name)))
                return False
            listener = Session().query(models.Listener).filter(models.Listener.name == listener_name).first()

            # shut down the listener and remove it from the cache
            if self.mainMenu.listeners.get_listener_module(listener_name) == 'redirector':
                del self.activeListeners[listener_name]
                Session().delete(listener)
                continue

            self.shutdown_listener(listener_name)

            # remove the listener from the database
            Session().delete(listener)
        Session().commit()

    def delete_listener(self, listener_name):
        """
        Delete listener(s) from database.
        """

        try:
            listeners = Session().query(models.Listener).all()

            db_names = [x['name'] for x in listeners]
            if listener_name.lower() == "all":
                names = db_names
            else:
                names = [listener_name]

            for name in names:
                if not name in db_names:
                    print(helpers.color("[!] Listener '%s' does not exist!" % name))
                    return False

                if name in list(self.activeListeners.keys()):
                    self.shutdown_listener(name)

                listener = Session().query(models.Listener).filter(models.Listener.name == name).first()
                Session().delete(listener)
            Session().commit()

        except Exception as e:
            print(helpers.color("[!] Error deleting listener '%s'" % name))

    def shutdown_listener(self, listenerName):
        """
        Shut down the server associated with a listenerName, but DON'T
        delete it from the database.
        """

        if listenerName.lower() == 'all':
            listenerNames = list(self.activeListeners.keys())
        else:
            listenerNames = [listenerName]

        for listenerName in listenerNames:
            if listenerName not in self.activeListeners:
                print(helpers.color("[!] Listener '%s' doesn't exist!" % (listenerName)))
                return False

            # retrieve the listener module for this listener name
            activeListenerModuleName = self.activeListeners[listenerName]['moduleName']
            activeListenerModule = self.loadedListeners[activeListenerModuleName]

            if activeListenerModuleName == 'redirector':
                print(helpers.color(
                    "[!] skipping redirector listener %s. Start/Stop actions can only initiated by the user." % (
                        listenerName)))
                continue

            # signal the listener module to shut down the thread for this particular listener instance
            activeListenerModule.shutdown(name=listenerName)

            # remove the listener object from the internal cache
            del self.activeListeners[listenerName]

    def disable_listener(self, listener_name):
        """
        Wrapper for shutdown_listener(), also marks listener as 'disabled' so it won't autostart
        """
        active_listener_module_name = self.activeListeners[listener_name]['moduleName']

        listener = Session().query(models.Listener).filter(
            and_(models.Listener.name == listener_name.lower(), models.Listener.module != 'redirector')).first()
        listener.enabled = False

        self.shutdown_listener(listener_name)
        Session().commit()

        # dispatch this event
        message = "[*] Listener {} disabled".format(listener_name)
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="listeners/{}/{}".format(active_listener_module_name, listener_name))

    def is_listener_valid(self, name):
        return name in self.activeListeners

    def is_loaded_listener_valid(self, name):
        return name in self.loadedListeners

    def get_listener_id(self, name):
        """
        Resolve a name to listener ID.
        """
        results = Session().query(models.Listener.id).filter(
            or_(models.Listener.name == name, models.Listener.id == name)).first()

        if results:
            return results[0]
        else:
            return None

    def get_listener_name(self, listener_id):
        """
        Resolve a listener ID to a name.
        """
        results = Session().query(models.Listener.name).filter(
            or_(models.Listener.name == listener_id, models.Listener.id == listener_id)).first()

        if results:
            return results[0]
        else:
            return None

    def get_listener_module(self, listener_name):
        """
        Resolve a listener name to the module used to instantiate it.
        """
        results = Session().query(models.Listener.module).filter(models.Listener.name == listener_name).first()

        if results:
            return results[0]
        else:
            return None

    def get_listener_names(self):
        """
        Return all current listener names.
        """
        return list(self.activeListeners.keys())

    def get_inactive_listeners(self):
        """
        Returns any listeners that are not currently running
        """
        db_listeners = Session().query(models.Listener).filter(models.Listener.enabled == False).all()

        inactive_listeners = {}
        for listener in db_listeners:
            inactive_listeners[listener['name']] = {'moduleName': listener['module'],
                                                    'options': listener['options']}

        return inactive_listeners

    def update_listener_options(self, listener_name, option_name, option_value):
        """
        Updates a listener option in the database
        """
        listener = Session().query(models.Listener).filter(models.Listener.name == listener_name).first()

        if not listener:
            print(helpers.color("[!] Listener %s not found" % listener_name))
            return False
        if option_name not in list(listener.options.keys()):
            print(helpers.color("[!] Listener %s does not have the option %s" % (listener_name, option_name)))
            return False
        listener.options[option_name]['Value'] = option_value
        flag_modified(listener, 'options')
        Session().commit()
        return True
