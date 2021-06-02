import requests

def public_key(site):
    requisicao = requests.get(site)
    return requisicao.text
