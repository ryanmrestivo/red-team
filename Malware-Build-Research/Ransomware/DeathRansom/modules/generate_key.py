from Crypto.PublicKey import RSA

new_key = RSA.generate(4096, e=65537)
private_key = new_key.exportKey("PEM")
public_key = new_key.publickey().exportKey("PEM")

with open('public.key','wb') as e:
    e.write(public_key)
    e.close()

with open('private.key','wb') as e:
    e.write(private_key)
    e.close()

print '[+] Private and Public keys have been sucessfuly generated'