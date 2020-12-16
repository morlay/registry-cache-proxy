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

DEBUG ?= 1
NAMESPACE ?= default

HELM ?= helm upgrade --install --create-namespace
ifeq ($(DEBUG),1)
	HELM = helm template --dependency-update
endif

cr:
	$(HELM) \
	  --namespace=$(NAMESPACE) \
	  --set=baseHost=$(BASE_HOST) \
	  --set=remoteurl=$(CONTAINER_REGISTRY_URL) \
	  --set=username=$(CONTAINER_REGISTRY_USERNAME) \
	  --set=password=$(CONTAINER_REGISTRY_PASSWORD) \
	  $(CONTAINER_REGISTRY_NAME) ./components/registry

cr.%:
	CONTAINER_REGISTRY=$* $(MAKE) cr

npm:
	$(HELM) \
	  --namespace=$(NAMESPACE) \
      --set=verdaccio.ingress.hosts[0]=npm.$(BASE_HOST) \
      npm ./components/npm
