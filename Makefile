DOCKER_HOST ?=
DEBUG ?= 1

DOCKER = $(DOCKER_HOST) docker

ifeq ($(DEBUG), 1)
	DOCKER := echo $(DOCKER)
endif

BASE_HOST ?= x.io
CONTAINER_REGISTRY ?= docker.io
CONTAINER_REGISTRY_NAME ?= $(subst .,-,$(subst .io,,$(CONTAINER_REGISTRY)))
CONTAINER_REGISTRY_URL ?= https://${CONTAINER_REGISTRY}
ifeq ($(CONTAINER_REGISTRY),docker.io)
	CONTAINER_REGISTRY_URL = https://registry-1.$(CONTAINER_REGISTRY)
endif

CONTAINER_REGISTRY_USERNAME = ${$(shell echo $(CONTAINER_REGISTRY_NAME) | tr '[:lower:]' '[:upper:]')_USERNAME}
CONTAINER_REGISTRY_PASSWORD = ${$(shell echo $(CONTAINER_REGISTRY_NAME) | tr '[:lower:]' '[:upper:]')_PASSWORD}

crs: cr.docker.io cr.gcr.io cr.ghcr.io cr.quay.io cr.k8s.gcr.io

gen:
	mkdir -p config
	helm template \
	--set=remoteurl=$(CONTAINER_REGISTRY_URL) \
	--set=username=$(CONTAINER_REGISTRY_USERNAME) \
	--set=password=$(CONTAINER_REGISTRY_PASSWORD) \
	$(CONTAINER_REGISTRY_NAME) ./registry-cache-proxy-config > config/$(CONTAINER_REGISTRY_NAME).yml

cr:
	$(DOCKER) stop $(CONTAINER_REGISTRY_NAME) || true && $(DOCKER) rm $(CONTAINER_REGISTRY_NAME) || true
	$(DOCKER) run -d \
		--name=$(CONTAINER_REGISTRY_NAME) \
		--restart=always \
		-v=$(PWD)/config/$(CONTAINER_REGISTRY_NAME).yml:/etc/docker/registry/config.yml \
		-v=/tmp/data/$(CONTAINER_REGISTRY_NAME):/var/lib/registry \
		--label=io.docksal.virtual-host=$(CONTAINER_REGISTRY_NAME).$(BASE_HOST) \
		--label=io.docksal.virtual-port=5000 \
		registry:2

cr.%:
	CONTAINER_REGISTRY=$* $(MAKE) gen cr

npm:
	$(DOCKER) stop npm || true && $(DOCKER) rm npm || true
	$(DOCKER) run -d \
		--name=npm \
		--restart=always \
		--label=io.docksal.virtual-host=npm.$(BASE_HOST) \
		--label=io.docksal.virtual-port=4873 \
		verdaccio/verdaccio:4

vhost:
	$(DOCKER) stop vhost || true && $(DOCKER) rm vhost || true
	$(DOCKER) run -d \
		--name=vhost \
		-p=80:80 \
		-p=443:443 \
		-v=/var/run/docker.sock:/var/run/docker.sock \
		--privileged \
		--restart=always \
		--label=io.docksal.group=system \
		docksal/vhost-proxy:latest
