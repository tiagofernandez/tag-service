APP := feature-flags
NS := tag-system
VERSION := 1.0.0-SNAPSHOT

define HELP

Usage:
    make help                  show available commands

    make clean                 remove build files and cached files
    make build                 compile packages and dependencies
    make deploy                deploy artifact to kubernetes cluster
endef

export HELP

default: help

help:
	@echo "$$HELP"

clean:
	./gradlew clean

build: clean
	./gradlew build -x test

deploy: build
	kubectl delete configmap $(APP) --ignore-not-found=true -n $(NS)
	kubectl create configmap $(APP) --from-file=build/libs/$(APP)-$(VERSION).jar -n $(NS)
