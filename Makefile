bold=$(shell (tput bold))
normal=$(shell (tput sgr0))
.DEFAULT_GOAL=help
DISTRIB:=$(shell lsb_release -is | tr '[:upper:]' '[:lower:]')
VERSION:=$(shell lsb_release -cs)
ARCHITECTURE:=$(shell dpkg --print-architecture)

help:
	@echo "${bold}install${normal}\n\t Installs the whole appplication. To use at the first installation.\n"
	@echo "${bold}uninstall${normal}\n\t Stops and removes containers and drops the database.\n"
	@echo "${bold}start${normal}\n\t Starts the application.\n"
	@echo "${bold}db.connect${normal}\n\t Connects to the database.\n"
	@echo "${bold}phpunit.run${normal}\n\t Runs the unit tests.\n"

start:
	docker-compose up --build -d
	sleep 3

stop:
	docker-compose down -v
	docker-compose rm -v

install: uninstall start composer.install db.install

depedencies: /usr/bin/docker /usr/local/bin/docker-compose

/usr/bin/docker:
	sudo apt-get update
	sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
	curl -fsSL https://download.docker.com/linux/${DISTRIB}/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=${ARCHITECTURE}] https://download.docker.com/linux/${DISTRIB} ${VERSION} stable"
	sudo apt-get update
	sudo apt-get install docker-ce

/usr/local/bin/docker-compose:
	sudo curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose version

uninstall: stop
	@sudo rm -rf postgres-data

reinstall: install

#Connects to the databatase
db.connect:
	docker-compose exec postgres /bin/bash -c 'psql -U $$POSTGRES_USER'

db.install:
	docker-compose exec postgres /bin/bash -c 'psql -U $$POSTGRES_USER -h localhost -f data/db.sql'

php.connect:
	docker-compose exec php /bin/bash

phpunit.run:
	docker-compose exec php vendor/bin/phpunit --config=phpunit.xml

composer.install:
	docker-compose exec php composer install || exit 0
