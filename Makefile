# NB: ensure you are in the docker group
# newgrp docker

-include protected/settings.mk

help:
	@echo The following makefile targets are available:
	@echo
	@grep -e '^\w\S\+\:' Makefile | sed 's/://g' | cut -d ' ' -f 1

###
# docker compose

up:
	docker-compose up

down:
	docker-compose down

###
# docker container

container-build:
	docker build --tag 0xidm/plenny-oracle:latest .

container-shell-dev:
	@echo "use this invocation during development; relies on environment in ./config"
	docker run -v $$PWD/config:/home/plenny/.plenny-oracle --rm -it --entrypoint /bin/bash 0xidm/plenny-oracle:latest

container-shell-prod:
	@echo "invoke on a deployment host"
	docker run -v /home/plenny/.plenny-oracle:/home/plenny/.plenny-oracle --rm -it --entrypoint /bin/bash 0xidm/plenny-oracle:latest

###
# protected configuration management

encrypt:
	openssl des3 < ./protected/$(PLENNY_ENV).ini > ./protected/$(PLENNY_ENV).ini.des3

decrypt:
	openssl des3 -d < ./protected/$(PLENNY_ENV).ini.des3 > ./protected/$(PLENNY_ENV).ini

unlock:
	openssl des3 -d < ./protected/$(PLENNY_ENV).ini.des3 \
    	| ssh $(PLENNY_SSH_RUNNER) "cat > /home/plenny/.plenny-oracle/plenny-env.ini"
	@echo "Unlocked; Launching PlennyOracle on server"

###
# bypass git to push directly to production

push:
	rsync -a --exclude=.git --exclude=protected --delete ./ $(PLENNY_SSH_SRC):/usr/local/src/plenny-oracle/

.PHONY: all build push
