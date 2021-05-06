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

init: docker-clear up api-permissions setup-composer setup-backend-env generate-keys

bash: ## Bash to app container
	docker exec -it $(APP_NAME)_php bash

docker-clear:
	docker-compose down --remove-orphans
	sudo rm -rf postgresql/maindb/data

docker-restart:
	docker-compose down
	docker-compose up --build -d

up:
	docker-compose up --build -d

down:
	docker-compose down --remove-orphans

pause:
	sleep 3

api-permissions:
	sudo chmod -R 777 ../backend.api/storage

setup-backend-env:
	(cd ../backend.api && cp -f .env.example .env)

setup-backend-openapi:
	docker exec -w /var/www/backend.api r2m_php php artisan openapi-build

setup-composer:
	docker exec -w /var/www/backend.api r2m_php composer update
	docker exec -w /var/www/backend.api r2m_php composer run-script post-create-project-cmd

generate-keys:
	docker exec -w /var/www/backend.api r2m_php composer run-script post-create-project-cmd
