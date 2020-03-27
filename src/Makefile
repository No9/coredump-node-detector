# Copyright IBM Corp. 2013,2018. All Rights Reserved.
# This file is licensed under the MIT License.
# License text available at https://opensource.org/licenses/MIT

dpl ?= build.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

.PHONY: clean help local image push all base pushbase

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

image: ## Builds kcdt in an image then creates a run image based on hte build.env params.
	@docker build --no-cache -t $(DOCKER_REPO)/$(APP_NAME):$(VERSION_TAG) .

push: ## Push image to your a docker repo.
	@docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION_TAG)

tag: ## Creates a tag for git
	@git tag $(VERSION_TAG) && git push origin $(VERSION_TAG)


all: ## Run image and push as one command.
	make image
	make tag
