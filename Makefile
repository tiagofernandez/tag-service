#!make
-include .env
export

ifeq (, $(shell which go))
    $(error "Please install Go: https://golang.org/doc/install")
endif

ifeq (, $(shell which yarn))
    $(error "Please install Yarn: https://classic.yarnpkg.com/en/docs/install/")
endif

IMAGE := tag-server
TAG := latest

define HELP

Usage:
    make help                  show available commands

    make init                  initialize git repo
    make install               download modules and install dependencies
    make clean                 remove object files and cached files
    make build                 compile packages and dependencies
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

build: clean
	go build .
	cd web && yarn build

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
	docker build --rm=true --squash -t $(IMAGE):$(TAG) .

docker-run:
	docker run --restart=always -p 6060:6060 -d $(IMAGE):$(TAG)

docker-run-shell:
	docker run -p 6060:6060 -ti $(IMAGE):$(TAG) /bin/sh

docker-debug:
	docker exec -ti $(shell docker ps | grep $(IMAGE):$(TAG) | awk '{print $$1}') /bin/sh

docker-stop:
	docker stop $(shell docker ps | grep $(IMAGE):$(TAG) | awk '{print $$1}')
