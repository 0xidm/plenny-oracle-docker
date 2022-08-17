FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
# Configuure ARG PLENNY_VERSION below

RUN \
  apt-get update && \
  apt-get install -y apt-utils && \
  apt-get upgrade -y && \
  apt-get --purge remove -y .\*-doc$ && \
  apt-get clean -y && \
  apt-get install -y \
    sudo \
    gnupg \
    vim \
    git \
    git-core \
    make \
    wget \
    curl \
    procps \
    openssh-server \
    tzdata \
    htop \
    telnet \
    net-tools \
    tmux \
    iftop \
    unzip \
    && \
  apt-get --purge remove -y .\*-doc$ && \
  apt-get clean -y

COPY ./bin /root/.local/bin
RUN /root/.local/bin/nvm-install.sh
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && nvm install 10.16.3"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && nvm use 10.16.3"]

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

COPY ./files/PlennyDLSP_Linux_x86_64-v$PLENNY_VERSION.zip /opt/PlennyDLSP_Linux_x86_64.zip
RUN unzip /opt/PlennyDLSP_Linux_x86_64.zip -d /opt \
  && chown -R root:root /opt/PlennyDLSP_Linux_x86_64 \
  && chmod 755 /opt/PlennyDLSP_Linux_x86_64/PlennyDLSP \
  && rm /opt/PlennyDLSP_Linux_x86_64/.env \
  && ln -s /home/plenny/.plenny-oracle/plenny-env.ini /opt/PlennyDLSP_Linux_x86_64/.env \
  && chown -R plenny:plenny /opt/PlennyDLSP_Linux_x86_64/server

# install nvm and node modules in the PlennyOracle path
WORKDIR /opt/PlennyDLSP_Linux_x86_64
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && npm install"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && npm install node-pre-gyp"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && npm install grpc"]

RUN mkdir -p /opt/PlennyDLSP_Linux_x86_64/server/certificates \
  && openssl genrsa -out /opt/PlennyDLSP_Linux_x86_64/server/certificates/key.pem \
  && openssl req -new -key /opt/PlennyDLSP_Linux_x86_64/server/certificates/key.pem -out /opt/PlennyDLSP_Linux_x86_64/server/certificates/csr.pem -subj "/C=US/ST=New York/L=New York/O=localhost/OU=localhost/CN=localhost" \
  && openssl x509 -req -days 9999 -in /opt/PlennyDLSP_Linux_x86_64/server/certificates/csr.pem -signkey /opt/PlennyDLSP_Linux_x86_64/server/certificates/key.pem -out /opt/PlennyDLSP_Linux_x86_64/server/certificates/cert.pem \
  && chown plenny:plenny /opt/PlennyDLSP_Linux_x86_64/server/certificates/*

# become user plenny
USER plenny

CMD ["/opt/PlennyDLSP_Linux_x86_64/PlennyDLSP"]
