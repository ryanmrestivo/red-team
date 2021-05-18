#!/usr/bin/env python3
# encoding: utf-8
from cortexutils.responder import Responder
import smtplib
import ssl
import requests
import json
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

class Phish_Feedback(Responder):

    def __init__(self):
        Responder.__init__(self)
        self.smtp_host = self.get_param(
            'config.smtp_host', 'localhost')
        self.smtp_port = self.get_param(
            'config.smtp_port', '25')
        self.smtp_user = self.get_param(
            'config.smtp_user', 'user')
        self.smtp_pwd = self.get_param(
            'config.smtp_pwd', 'pwd')
        self.mail_from = self.get_param(
            'config.from', None, 'Missing sender email address')

        self.mode = self.get_param('data.customFields.phishFeedback.string', None)
        if not self.mode:
             self.report({"Error" : "Custom field 'phish_feedback' was not set"})


    def run(self):
        Responder.run(self)
        title = self.get_param('data.title', None, 'Title is missing')
        if title.find("Phishing report") == -1:
                self.report({"response" : "Phish_Feedback is only applicable to cases which title starts with 'Phishing report'"})
        # Search recipient address in tags
        tags = self.get_param('data.tags', None, 'recipient address not found in tags')
        mail_tags = [t[11:] for t in tags if t.startswith('user_email:')]
        if mail_tags:
            mail_to = mail_tags.pop()
        else:
			self.report({"Error" : "Recipient address not found in observable"})

        if self.mode == "Phishing":
                description = """\rGreetings,
                         \rYou've recently reported a spear-phishing attempt to us'.
                         \rWe would like to congratulate you for spotting this attempt beacause it was indeed a malicious email!
                         \rThank you,
                        """

        elif self.mode == "Legit email":
                description = """\rGreetings,
                         \rYou've recently reported a spear-phishing attempt to us.
                         \rWe thank you for your submission , however  we would like to inform you that this email was legitimate. Can you please tell us why you thought it was malicious ?
                         \rIf you want tips on how to detect phishing emails , please check:
                         \rhttps://campagne.safeonweb.be/en/phishing
                         \rThank you,
                    """

        elif self.mode == "Spam":
                description = """\rGreetings,
                         \rYou've recently reported a spear-phishing attempt to us.
                         \rWe thank you for your submission , but we would like to inform you that this email was not malicious but just ordinary spam.
                         \rIf you would like tips on how to detect phishing emails , please check:
                         \rhttps://campagne.safeonweb.be/en/phishing
                         \rThank you
                         \r
                    """

        msg = MIMEMultipart()
        msg['Subject'] = "Phishing report feedback"
        msg['From'] = self.mail_from
        msg['To'] = mail_to
        msg.attach(MIMEText(description, 'plain'))

        context = ssl.SSLContext(ssl.PROTOCOL_TLS)
        server = smtplib.SMTP(self.smtp_host, self.smtp_port)
        server.starttls(context=context)
        server.login(self.smtp_user, self.smtp_pwd)
        server.sendmail(self.mail_from, mail_to, msg.as_string())
        server.quit()

        self.report({'Status': 'Mail sent'})

    def operations(self, raw):
        return [self.build_operation('AddTagToCase', tag='mail sent')]

if __name__ == '__main__':
        Phish_Feedback().run()
