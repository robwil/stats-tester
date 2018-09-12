PROJECT_NAME := stats-tester
DOCKER_REGISTRY ?= us.gcr.io/bx-preflight
DOCKER_TAG ?= $(shell date +%Y%m%d).$(shell git log --pretty=format:'%h' -n 1)
DOCKER_FULL_TAGNAME ?= $(DOCKER_REGISTRY)/$(PROJECT_NAME):$(DOCKER_TAG)

.PHONY: docker_build
docker_build: ## Builds a container of the app, tagged with DOCKER_FULL_TAGNAME.
	@echo "building $(DOCKER_FULL_TAGNAME)..."
	@docker build --no-cache -t $(DOCKER_FULL_TAGNAME) .

.PHONY: gregistry_auth
gregistry_auth: ## GCP authentication for docker
	@echo "docker login for GCP..."
	@gcloud auth configure-docker

.PHONY: push
push: docker_build gregistry_auth ## Builds and pushes DOCKER_FULL_TAGNAME to GCP
	@echo "pushing $(DOCKER_FULL_TAGNAME)..."
	@docker push $(DOCKER_FULL_TAGNAME)

.PHONY: help
help: ## Lists useful commands. Other commands may be available, but are not generally useful for most purposes. Read the Makefile for these additional commands.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help