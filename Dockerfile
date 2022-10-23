FROM --platform=linux/amd64 node:10-stretch-slim

RUN apt update && apt -y install unzip

ARG PLENNY_VERSION=3.1.4-Beta

COPY ./files/PlennyDLSP_Linux_x86_64-v$PLENNY_VERSION.zip /tmp/PlennyDLSP_Linux_x86_64.zip

RUN unzip /tmp/PlennyDLSP_Linux_x86_64.zip -d /tmp \
  && chown -R root:root /tmp/PlennyDLSP_Linux_x86_64 \
  && chmod 755 /tmp/PlennyDLSP_Linux_x86_64/PlennyDLSP \
  && rm -rf /tmp/PlennyDLSP_Linux_x86_64/server \
  && mkdir /tmp/PlennyDLSP_Linux_x86_64/server \
  && rm /tmp/PlennyDLSP_Linux_x86_64/.env \
  && mv /tmp/PlennyDLSP_Linux_x86_64 /opt/PlennyDLSP_Linux_x86_64 \
  && rm /tmp/PlennyDLSP_Linux_x86_64.zip

WORKDIR /opt/PlennyDLSP_Linux_x86_64

RUN npm install \
  && npm install node-pre-gyp grpc

RUN chown -R node:node /opt/PlennyDLSP_Linux_x86_64

VOLUME [ "/opt/PlennyDLSP_Linux_x86_64/server" ]
VOLUME [ "/opt/PlennyDLSP_Linux_x86_64/.env" ]

USER node
CMD "./PlennyDLSP"
