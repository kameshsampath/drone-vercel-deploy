CURRENT_DIR = $(shell pwd)
PLUGIN_IMAGE_NAME := docker.io/kameshsampath/drone-vercel-deploy
DRONE_FILE = .drone.yml

build-and-load:	## Builds and loads the image into local docker context
	@docker buildx build \
  --tag $(PLUGIN_IMAGE_NAME) \
  --load \
  -f "$(CURRENT_DIR)/docker/Dockerfile" "$(CURRENT_DIR)" 

deploy-and-test:	build-and-load ## Builds, loads the image into local docker and tests
	@drone exec --secret-file="examples/nextjs-blog/secret.local" examples/nextjs-blog/.drone.yml

build-and-push:	## Builds and pushes the image to Container Registry
	@docker buildx build \
  --build-arg BUILDKIT_MULTI_PLATFORM=1 \
  --platform=linux/amd64 \
  --platform=linux/arm64 \
  --push \
  --metadata-file="$(CURRENT_DIR)/docker/metadata.json" \
  --tag $(PLUGIN_IMAGE_NAME) \
  -f "$(CURRENT_DIR)/docker/Dockerfile" "$(CURRENT_DIR)"

help: ## Show this help
	@echo Please specify a build target. The choices are:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(INFO_COLOR)%-30s$(NO_COLOR) %s\n", $$1, $$2}'

.PHONY:	build-and-load	build-and-push