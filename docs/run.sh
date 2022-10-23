#!/bin/bash

docker run --rm -it --platform=linux/amd64 \
    -v "/home/plenny/.plenny:/opt/PlennyDLSP_Linux_x86_64/.env" \
    -v plenny-oracle:/opt/PlennyDLSP_Linux_x86_64/server \
    0xidm/plenny-oracle:latest
