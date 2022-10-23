# NB: ensure you are in the docker group
# newgrp docker

-include protected/settings.mk

help:
	@echo The following makefile targets are available:
	@echo
	@grep -e '^\w\S\+\:' Makefile | sed 's/://g' | cut -d ' ' -f 1

###
# docker

build:
	docker build --network host --tag 0xidm/plenny-oracle:latest .

run:
	docker run --rm -it --network host --platform=linux/amd64 \
		-v ${PWD}/protected/mainnet.ini:/opt/PlennyDLSP_Linux_x86_64/.env \
		-v ${PWD}/protected/server:/opt/PlennyDLSP_Linux_x86_64/server \
		0xidm/plenny-oracle:latest

run-shell:
	docker run --rm -it --network host --platform=linux/amd64 \
		-v plenny-oracle:/opt/PlennyDLSP_Linux_x86_64/server \
		0xidm/plenny-oracle:latest \
		/bin/bash

shell:
	docker exec -it plenny-oracle /bin/bash

###
# protected configuration management

encrypt:
	openssl des3 < ./protected/$(PLENNY_ENV).ini > ./protected/$(PLENNY_ENV).ini.des3

decrypt:
	openssl des3 -d < ./protected/$(PLENNY_ENV).ini.des3 > ./protected/$(PLENNY_ENV).ini

unlock:
	openssl des3 -d < ./protected/$(PLENNY_ENV).ini.des3 \
    	| ssh $(PLENNY_SSH_RUNNER) "cat > /home/plenny/.plenny"
	@echo "Unlocked; Launching PlennyOracle on server"

fifo:
	ssh $(PLENNY_SSH_RUNNER) "mkfifo /home/plenny/.plenny"
