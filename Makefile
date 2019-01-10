VERSION ?= $(shell git describe --always --tags)
BIN = oauth2_proxy
BUILD_CMD = go build -o build/$(BIN)
IMAGE_REPO = jenkinsxio

default:
	$(MAKE) bootstrap
	$(MAKE) build

bootstrap:
	dep ensure

build:
	go build -o $(BIN)

test: bootstrap
	go vet ./...
	go test -covermode=atomic -race -v ./...

lint:
	golint -set_exit_status $(shell go list ./... | grep -v vendor)

clean:
	rm -rf build vendor
	rm -f release image bootstrap $(BIN)

release: bootstrap
	@echo "Running build command..."
	sh -c '\
		export GOOS=linux; export GOARCH=amd64; export CGO_ENABLED=0; $(BUILD_CMD) & \
		wait \
	'

image: 
	@echo "Building the Docker image..."
	docker build -t $(IMAGE_REPO)/$(BIN):$(VERSION) .
	docker tag $(IMAGE_REPO)/$(BIN):$(VERSION) $(IMAGE_REPO)/$(BIN):latest

image-push: image
	docker push $(IMAGE_REPO)/$(BIN):$(VERSION)
	docker push $(IMAGE_REPO)/$(BIN):latest

.PHONY: test build clean image-push

