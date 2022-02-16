FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update && \
  apt-get install -y apt-utils && \
  apt-get upgrade -y && \
  apt-get --purge remove -y .\*-doc$ && \
  apt-get clean -y

RUN \
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
    && \
  apt-get --purge remove -y .\*-doc$ && \
  apt-get clean -y

###
# Add a basic user

RUN adduser \
  --home "/home/plenny" \
  --uid 1620 \
  --gecos "plenny" \
  --disabled-password \
  "plenny"

RUN chown -R plenny:plenny /home/plenny

# install PlennyOracle
COPY ./files/PlennyOracle_Linux_x86_64-v3.0.0-Beta.tar.gz /opt/PlennyOracle_Linux_x86_64.tar.gz
RUN tar xfz /opt/PlennyOracle_Linux_x86_64.tar.gz -C /opt
RUN chown -R root:root /opt/PlennyOracle_Linux_x86_64

RUN rm /opt/PlennyOracle_Linux_x86_64/.env
RUN ln -s /home/plenny/.plenny-oracle/plenny-env.ini /opt/PlennyOracle_Linux_x86_64/.env
RUN chown -R plenny:plenny /opt/PlennyOracle_Linux_x86_64/server

# install nvm and node modules in the PlennyOracle path
COPY ./bin /root/.local/bin
WORKDIR /opt/PlennyOracle_Linux_x86_64
RUN /root/.local/bin/nvm-install.sh
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && nvm install 10.16.3"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && nvm use 10.16.3"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && npm install"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && npm install node-pre-gyp"]
RUN ["/bin/bash", "-c", "source /root/.local/bin/nvm-bash.sh && npm install grpc"]

RUN mkdir -p /opt/PlennyOracle_Linux_x86_64/server/certificates
RUN openssl genrsa -out /opt/PlennyOracle_Linux_x86_64/server/certificates/key.pem
RUN openssl req -new -key /opt/PlennyOracle_Linux_x86_64/server/certificates/key.pem -out /opt/PlennyOracle_Linux_x86_64/server/certificates/csr.pem -subj "/C=US/ST=New York/L=New York/O=localhost/OU=localhost/CN=localhost"
RUN openssl x509 -req -days 9999 -in /opt/PlennyOracle_Linux_x86_64/server/certificates/csr.pem -signkey /opt/PlennyOracle_Linux_x86_64/server/certificates/key.pem -out /opt/PlennyOracle_Linux_x86_64/server/certificates/cert.pem
RUN chown plenny:plenny /opt/PlennyOracle_Linux_x86_64/server/certificates/*

# become user plenny
USER plenny
