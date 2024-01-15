# Created By Enrique Plata
SHELL = /bin/bash

include .env

.DEFAULT_GOAL := help

.PHONY: build-docker-image-local
build-docker-image-local: ## 1.-Building docker image locally.
	@ echo "**********Cleaning container**********"
	# docker build --no-cache -t dbt-runner-image . # --no-cache
	docker build -t dbt-runner-image .

.PHONY: run-docker-container-local
run-docker-container-local: ## 2.-Running docker container locally.
	@ $(MAKE) build-docker-image-local
	@ echo "**********Running container**********"
	docker run --rm --name dbt-runner dbt-runner-image

.PHONY: run-docker-compose-local
run-docker-compose-local: ## 3.-Running docker compose locally.
	@ $(MAKE) check-account
	@ echo "**********Running docker compose**********"
	@ docker-compose up --build --remove-orphans

.PHONY: clean-docker-compose-local
clean-docker-compose-local: ## 4.-Running docker compose locally.
	@ echo "**********Cleaning docker compose**********"
	@ docker-compose down --remove-orphans

.PHONY: push-docker-image-registry
push-docker-image-registry: ## 5.-Pushing docker image to registry.
	@ $(MAKE) check-repository
	@ $(MAKE) build-docker-image-local
	@ echo "********** Tagging image to registry **********"
	@ docker tag dbt-runner-image $(IMAGEREPOSITORYURI)/dbt-runner-image
	@ echo "********** Pushing image to registry **********"
	docker push $(IMAGEREPOSITORYURI)/dbt-runner-image

.PHONY: upload-dbt-specs
upload-dbt-specs: ## 6.-Uploading dbt specs to specs stage.
	@ $(MAKE) check-repository
	@ echo "********** Uploading dbt specs to specs stage **********"
	@ snow stage put ./dbt-spec.yaml specs -c dbt --overwrite

.PHONY: check-repository
check-repository: ## 0.- Check if repository varialble is placed in .env file.
	@ echo "Checking if IMAGEREPOSITORYURI is set"
	$(if $(IMAGEREPOSITORYURI),,$(error Must set variable IMAGEREPOSITORYURI in .env file))
	@ echo $(IMAGEREPOSITORYURI)

.PHONY: check-account
check-account: ## 0. Check if Snowflake ACCOUNT variables are placed in .env file.
	@ echo "Checking if ACCOUNT is set"
	$(if $(ACCOUNT),,$(error Must set variable ACCOUNT in .env file))

help: ## 0.-Display all the different target recipes.
	@ echo "Please use \`make <target>' where <target> is one of"
	@ perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'
