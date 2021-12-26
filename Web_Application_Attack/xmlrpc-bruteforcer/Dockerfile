FROM python:3.9.0a2-alpine3.10

# add files to container build
ADD requirements.txt /
ADD xmlrpc-bruteforcer.py /

# install deps
RUN pip install -r /requirements.txt

# define script entrypoint
ENTRYPOINT [ "python", "/xmlrpc-bruteforcer.py" ]