FROM python:2.7.16-alpine3.10

ENV WORKDIR /src
RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

COPY ./requirements.txt ${WORKDIR}/requirements.txt
RUN pip install -r requirements.txt

COPY ./ ${WORKDIR}/

ENTRYPOINT ["python", "XssPy.py"]
