"""

Credential handling functionality for Empire.

"""
from __future__ import print_function
from __future__ import absolute_import

from builtins import input
from builtins import str
from builtins import object
from . import helpers
import os
from empire.server.database.base import Session
from empire.server.database import models
from sqlalchemy import or_, and_


class Credentials(object):
    """
    Class that handles interaction with the backend credential model
    (adding creds, displaying, etc.).
    """

    def __init__(self, MainMenu, args=None):

        # pull out the controller objects
        self.mainMenu = MainMenu
        self.installPath = self.mainMenu.installPath
        self.args = args

        # credential database schema:
        #   (ID, credtype, domain, username, password, host, OS, notes, sid)
        # credtype = hash or plaintext
        # sid is stored for krbtgt

    def is_credential_valid(self, credentialID):
        """
        Check if this credential ID is valid.
        """
        results = Session().query(models.Credential).filter(models.Credential.id == credentialID).all()
        return len(results) > 0

    def get_credentials(self, filter_term=None, credtype=None, note=None, os=None):
        """
        Return credentials from the database.

        'credtype' can be specified to return creds of a specific type.
        Values are: hash, plaintext, and token.
        """

        # if we're returning a single credential by ID
        if self.is_credential_valid(filter_term):
            results = Session().query(models.Credential).filter(models.Credential.id == filter_term).first()

        # if we're filtering by host/username
        elif filter_term and filter_term != '':
            filter_term = filter_term.replace('*', '%')
            search = "%{}%".format(filter_term)
            results = Session().query(models.Credential).filter(or_(models.Credential.domain.like(search),
                                                                    models.Credential.username.like(search),
                                                                    models.Credential.host.like(search),
                                                                    models.Credential.password.like(search))).all()

        # if we're filtering by credential type (hash, plaintext, token)
        elif credtype and credtype != "":
            results = Session().query(models.Credential).filter(models.Credential.credtype.ilike(f'%credtype%')).all()

        # if we're filtering by content in the note field
        elif note and note != "":
            search = "%{}%".format(note)
            results = Session().query(models.Credential).filter(models.Credential.note.ilike(f'%search%')).all()

        # if we're filtering by content in the OS field
        elif os and os != "":
            search = "%{}%".format(os)
            results = Session().query(models.Credential).filter(models.Credential.os.ilike('%search%')).all()

        # otherwise return all credentials
        else:
            results = Session().query(models.Credential).all()

        return results

    def get_krbtgt(self):
        """
        Return all krbtgt credentials from the database.
        """
        return self.get_credentials(credtype="hash", filterTerm="krbtgt")

    def add_credential(self, credtype, domain, username, password, host, os='', sid='', notes=''):
        """
        Add a credential with the specified information to the database.
        """
        results = Session().query(models.Credential).filter(and_(models.Credential.credtype.like(credtype),
                                                                 models.Credential.domain.like(domain),
                                                                 models.Credential.username.like(username),
                                                                 models.Credential.password.like(password))).all()

        if len(results) == 0:
            credential = models.Credential(credtype=credtype,
                                           domain=domain,
                                           username=username,
                                           password=password,
                                           host=host,
                                           os=os,
                                           sid=sid,
                                           notes=notes)
            Session().add(credential)
            Session().commit()
            return credential

    def add_credential_note(self, credential_id, note):
        """
        Update a note to a credential in the database.
        """
        results = Session().query(models.Agent).filter(models.Credential.id == credential_id).first()
        results.notes = note
        Session().commit()

    def remove_credentials(self, credIDs):
        """
        Removes a list of IDs from the database
        """
        for credID in credIDs:
            cred_entry = Session().query(models.Credential).filter(models.Credential.id == credID).first()
            Session().delete(cred_entry)
        Session().commit()

    def remove_all_credentials(self):
        """
        Remove all credentials from the database.
        """
        creds = Session().query(models.Credential).all()
        for cred in creds:
            Session().delete(cred)
        Session().commit()

    def export_credentials(self, export_path=''):
        """
        Export the credentials in the database to an output file.
        """

        if export_path == '':
            print(helpers.color("[!] Export path cannot be ''"))

        export_path += ".csv"

        if os.path.exists(export_path):
            try:
                choice = input(helpers.color("[>] File %s already exists, overwrite? [y/N] " % (export_path), "red"))
                if choice.lower() != "" and choice.lower()[0] == "y":
                    pass
                else:
                    return
            except KeyboardInterrupt:
                return

        creds = self.get_credentials()

        if len(creds) == 0:
            print(helpers.color("[!] No credentials in the database."))
            return

        with open(export_path, 'w') as output_file:
            output_file.write("CredID,CredType,Domain,Username,Password,Host,OS,SID,Notes\n")
            for cred in creds:
                output_file.write("\"%s\"\n" % ('","'.join([str(x) for x in cred])))

            print("\n" + helpers.color("[*] Credentials exported to %s\n" % (export_path)))
