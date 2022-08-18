FROM debian:buster-slim

RUN apt update \
  && apt -y install \
  bash \
  git \
  unzip \
  ca-certificates \
  openssl \
  nodejs \
  npm \
  && apt clean

###
# Add a basic user

RUN adduser \
  --home "/home/plenny" \
  --uid 1620 \
  --gecos "plenny" \
  --disabled-password \
  "plenny"

RUN chown -R plenny:plenny /home/plenny

###
# install PlennyOracle

ARG PLENNY_VERSION=3.1.4-Beta

COPY ./files/PlennyDLSP_Linux_x86_64-v$PLENNY_VERSION.zip /tmp/PlennyDLSP_Linux_x86_64.zip
RUN unzip /tmp/PlennyDLSP_Linux_x86_64.zip -d /tmp \
  && chown -R root:root /tmp/PlennyDLSP_Linux_x86_64 \
  && chmod 755 /tmp/PlennyDLSP_Linux_x86_64/PlennyDLSP \
  && rm -rf /tmp/PlennyDLSP_Linux_x86_64/server \
  && mv /tmp/PlennyDLSP_Linux_x86_64 /opt/PlennyDLSP_Linux_x86_64 \
  && rm /tmp/PlennyDLSP_Linux_x86_64.zip

VOLUME ["/opt/PlennyDLSP_Linux_x86_64/server", "/home/plenny/.plenny-oracle"]

RUN rm /opt/PlennyDLSP_Linux_x86_64/.env \
  && ln -s /home/plenny/.plenny-oracle/plenny-env.ini /opt/PlennyDLSP_Linux_x86_64/.env

WORKDIR /opt/PlennyDLSP_Linux_x86_64

RUN npm install \
  && npm install node-pre-gyp grpc

# become user plenny
USER plenny

CMD "/opt/PlennyDLSP_Linux_x86_64/PlennyDLSP"
