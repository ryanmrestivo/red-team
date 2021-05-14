FROM    ubuntu:20.04
WORKDIR /opt/koadic
RUN     apt-get update && apt-get install -y python3 python3-pip socat 
COPY    . /opt/koadic
RUN     pip3 install -r requirements.txt
ENTRYPOINT ["./koadic"]
