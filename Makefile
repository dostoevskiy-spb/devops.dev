ifeq ("$(wildcard .env)","")
    $(shell cp ../backend.api/.env.example .env)
endif

include .env
export $(shell sed 's/=.*//' .env)

dc := docker-compose
dc_arg := exec -T app
dc_exec_app := $(dc) $(dc_arg)
artisan := php artisan

hosts_file := /etc/hosts

docker_run_package :=
.DEFAULT_GOAL := help

up: docker-up

init: docker-clear docker-up api-permissions #setup-composer #setup-backend-env

exec-php: ## Bash to app container
	docker exec -it $(APP_NAME)_php bash

docker-clear:
	docker-compose down --remove-orphans
	sudo rm -rf postgresql/maindb/data

docker-restart:
	docker-compose down
	docker-compose up --build -d

docker-up:
	docker-compose up --build -d

pause:
	sleep 3

api-permissions:
	sudo chmod -R 777 ../backend.api/storage

setup-backend-env:
	(cd ../backend.api && cp -f .env.example .env)

setup-backend-openapi:
	docker exec -w /var/www/backend.api r2m_php php artisan openapi-build

setup-composer:
	docker exec -w /var/www/backend.api r2m_php composer install
