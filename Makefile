#!make
-include .env
export

ifeq (, $(shell which go))
    $(error "Please install Go: https://golang.org/doc/install")
endif

ifeq (, $(shell which yarn))
    $(error "Please install Yarn: https://classic.yarnpkg.com/en/docs/install/")
endif

APP := tag-service
NS := tag-system
ORG := brazur

IMAGE := github.com/$(ORG)/$(APP)
VERSION := latest
PORT := 6060

define HELP

Usage:
    make help                  show available commands

    make init                  initialize git repo
    make install               download modules and install dependencies
    make clean                 remove build files and cached files
    make build                 compile packages and dependencies
    make build-api             build the api server
    make build-web             build the web client
    make run                   compile and run the main program
    make run-api               run the api server in dev mode
    make run-web               run the web application in dev mode

    make shell                 start a go repl
    make format                format the source code
    make lint                  run lint inspections
    make test                  run unit tests
    make bench                 run test benchmarks
    make cover                 run test coverage checks
    make cover-report          generate test coverage report
    make doc                   generate html documentation

    make docker-clean          prune stopped containers and dangling images
    make docker-image          build the docker image
    make docker-run            launch a detached container
    make docker-run-shell      launch an interactive container
    make docker-debug          debug the running container
    make docker-stop           stop the detached container

    make k8s-cluster           create the kind cluster
    make k8s-dev               run the kubernetes app in dev mode
    make k8s-run               run the kubernetes app in detached mode
    make k8s-debug             debug the running service
endef

export HELP

default: help

help:
	@echo "$$HELP"

init:
	mkdir -p .git/hooks
	ln -sf ../../git-hooks/pre-commit .git/hooks/pre-commit
	ln -sf ../../git-hooks/pre-push .git/hooks/pre-push
	chmod -R 775 git-hooks
	cp .env.dev .env

install: init
	go mod download
	cd web && yarn install

clean:
	go clean
	rm -rf web/build/

build-api:
	go build .

build-web:
	cd web && yarn build

build: clean build-api build-web

run: build
	go run main.go

run-api:
	air

run-web:
	cd web && yarn start

shell:
	gore

format:
	go fmt ./...
	cd web && yarn format

lint:
	golint ./...
	go vet ./...
	cd web && yarn lint

test:
	go test -v ./...
	cd web && yarn test

bench:
	go test -bench ./...

cover:
	go test -cover ./...

cover-report:
	go test ./... -coverprofile cover.out
	go tool cover -html cover.out

doc:
	godoc -http :6070

docker-clean:
	docker system prune -f

docker-image: build
	docker build --rm=true -t $(IMAGE):$(VERSION) .

docker-run:
	docker run --restart=always -p $(PORT):$(PORT) -d $(IMAGE):$(VERSION)

docker-run-shell:
	docker run -p $(PORT):$(PORT) -ti $(IMAGE):$(VERSION) /bin/sh

docker-debug:
	docker exec -ti $(shell docker ps | grep $(IMAGE):$(VERSION) | awk '{print $$1}') /bin/sh

docker-stop:
	docker stop $(shell docker ps | grep $(IMAGE):$(VERSION) | awk '{print $$1}')

k8s-cluster:
	kind create cluster --name $(ORG) --config kind.yaml

k8s-dev:
	skaffold dev --port-forward

k8s-run: build
	skaffold run --port-forward

k8s-debug:
	kubectl exec -ti service/$(APP) -n $(NS) -- sh
