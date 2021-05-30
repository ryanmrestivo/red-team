#!/usr/bin/env python

encoding: utf-8
from cortexutils.responder import Responder

import requests
import json
import warnings
import sys
import os

class MispRelevantMarker(Responder):

def __init__(self):
    Responder.__init__(self)
    self.misp_url = self.get_param(
        'config.misp_url', 'localhost')
    self.misp_api_key = self.get_param(
        'config.misp_api_key', 'localhost')
    self.thehive_api_key = self.get_param(
        'config.TheHive_Api_Key', None, 'Missing TheHive API KEY')


def run(self):
    Responder.run(self)
    title = self.get_param('data.title', None, 'Title is missing')
    if title.find("#") == -1:
            self.error( "Responder is only applicable to imported Misp Event alerts")

    space_indx = title.index(" ")
    event_id =  title[1:space_indx]

    #add the Relevant tag in Misp to the linked event
    url = self.misp_url + "/events/addTag"
    data = {
                            "request": {"Event": {"id": event_id,
                                                                      "tag": "Relevant",
                                                                      "local" : "false"
                                                                     }
                                                    }
            }

    headers = {'Content-type': 'application/json', "Accept" : "application/json" ,'Authorization': self.misp_api_key}
    r = requests.post(url, json=data, headers=headers, verify = False, proxies=None)

    #publish it in Misp
    url = self.misp_url + "/events/publish/" + event_id
    r = requests.post(url, headers=headers, verify = False)

    #add tag to alert
    alert_id = self.get_param('data.id', None, 'alertId is missing')
    tags = self.get_param('data.tags', None, 'tags field missing')
    user = str(self.artifact["parameters"]["user"])
    tags.append("Set as relevant by : " + user)

    server = 'Your TheHive URL'
    uri = "/api/alert/" + alert_id
    url = server+uri
    query = {
               "tags": tags
    }

    jsondata = json.dumps(query)
    jsondatab = jsondata.encode('utf-8')

    #adds a tag in TheHive
    headers = {'Authorization': 'Bearer ' + self.thehive_api_key, 'Content-Type': 'application/json'}
    resp = requests.patch(url, data=jsondatab, headers=headers,verify=False)
   
    self.report({'Status': 'Event marked as Relevant in Misp'})



def operations(self, raw):
            pass
if name == 'main':
        MispRelevantMarker().run()

