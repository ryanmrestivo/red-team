from pyngrok import ngrok

def create_tunnel():
    try: 
        http_tunnel = ngrok.connect(8000, 'http')
        return(http_tunnel.public_url)
    except:
        print("An error occurred while starting the ngrok tunnel :( \nPlease visit https://github.com/CYBERDEVILZ/Cryptonite/discussions/47 to see how you can solve this issue :)")
        return(None)
