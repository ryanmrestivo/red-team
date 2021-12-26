import threading
import string
import random
import bcrypt
from . import helpers
import json
from pydispatch import dispatcher
from empire.server.database.base import Session
from empire.server.database import models

class Users(object):
    def __init__(self, mainMenu):
        self.mainMenu = mainMenu

        self.args = self.mainMenu.args

        self.users = {}

    def user_exists(self, uid):
        """
        Return whether a user exists or not
        """
        user = Session().query(models.User).filter(models.User.id == uid).first()
        if user:
            return True
        else:
            return False

    def add_new_user(self, user_name, password):
        """
        Add new user to cache
        """
        success = Session().add(models.User(username=user_name,
                                            password=self.get_hashed_password(password),
                                            enabled=True,
                                            admin=False
                                            ))
        Session().commit()

        if success:
            # dispatch the event
            signal = json.dumps({
                'print': True,
                'message': "Added {} to Users".format(user_name)
            })
            dispatcher.send(signal, sender="Users")
            message = True
        else:
            message = False

        return message

    def disable_user(self, uid, disable):
        """
        Disable user
        """
        user = Session().query(models.User).filter(models.User.id == uid).first()

        if not self.user_exists(uid):
                message = False
        elif self.is_admin(uid):
            signal = json.dumps({
                'print': True,
                'message': "Cannot disable admin account"
            })
            message = False
        else:
            user.enabled = not(disable)
            Session.commit()

            signal = json.dumps({
                'print': True,
                'message': 'User {}'.format('disabled' if disable else 'enabled')
            })
            message = True

        dispatcher.send(signal, sender="Users")
        return message

    def user_login(self, user_name, password):
        user = Session().query(models.User).filter(models.User.username == user_name).first()
            
        if user is None:
            return None

        if not self.check_password(password, user.password):
            return None

        user.api_token = user.api_token or self.refresh_api_token()
        user.username = user_name
        Session.commit()

        # dispatch the event
        signal = json.dumps({
            'print': False,
            'message': "[+] {} connected".format(user_name)
        })
        dispatcher.send(signal, sender="Users")
        return user.api_token

    def get_user_from_token(self, token):
        user = Session().query(models.User).filter(models.User.api_token == token).first()

        if user:
            return {'id': user.id, 'username': user.username, 'api_token': user.api_token, 'last_logon_time': user.last_logon_time, 'enabled': user.enabled, 'admin': user.admin, "notes": user.notes}

        return None

    def update_username(self, uid, username):
        """
        Update a user's username.
        Currently only when empire is start up with the username arg.
        """
        user = Session().query(models.User).filter(models.User.id == uid).first()
        user.username = username
        Session.commit()

        # dispatch the event
        signal = json.dumps({
            'print': True,
            'message': "Username updated"
        })
        dispatcher.send(signal, sender="Users")

        return True

    def update_password(self, uid, password):
        """
        Update the last logon timestamp for a user
        """
        if not self.user_exists(uid):
            return False

        user = Session().query(models.User).filter(models.User.id == uid).first()
        user.password = self.get_hashed_password(password)
        Session.commit()

        # dispatch the event
        signal = json.dumps({
            'print': True,
            'message': "Password updated"
        })
        dispatcher.send(signal, sender="Users")

        return True

    def user_logout(self, uid):
        user = Session().query(models.User).filter(models.User.id == uid).first()
        user.api_token = ''
        Session.commit()

        # dispatch the event
        signal = json.dumps({
            'print': True,
            'message': "User disconnected"
        })
        dispatcher.send(signal, sender="Users")

    def refresh_api_token(self):
        """
        Generates a randomized RESTful API token and updates the value
        in the config stored in the backend database.
        """
        # generate a randomized API token
        rng = random.SystemRandom()
        apiToken = ''.join(rng.choice(string.ascii_lowercase + string.digits) for x in range(40))

        return apiToken

    def is_admin(self, uid):
        """
        Returns whether a user is an admin or not.
        """
        admin = Session().query(models.User.admin).filter(models.User.id == uid).first()

        if admin[0] == True:
            return True

        return False

    def get_hashed_password(self, plain_text_password):
        if isinstance(plain_text_password,str):
            plain_text_password = plain_text_password.encode('UTF-8')

        return bcrypt.hashpw(plain_text_password, bcrypt.gensalt())

    def check_password(self, plain_text_password, hashed_password):
        if isinstance(plain_text_password,str):
            plain_text_password = plain_text_password.encode('UTF-8')
        if isinstance(hashed_password,str):
            hashed_password = hashed_password.encode('UTF-8')

        return bcrypt.checkpw(plain_text_password, hashed_password)

