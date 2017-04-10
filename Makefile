.PHONY: build clean test image push check_docker docker_login release check_version
BUILD_VERSION = $(shell head -n 1 CHANGELOG.md | awk '{print $$2}')
DOCKER_REPO ?= vancluever
S3_KEY_PREFIX ?= $(DOCKER_REPO)
TF_CMD ?= apply -input=false
TF_DIR ?= terraform
export AWS_DEFAULT_REGION ?= ca-central-1

test:
	go test -v .

check_docker:
ifeq ($(DOCKER_USERNAME),)
	$(error Please define the DOCKER_USERNAME environment variable)
endif
ifeq ($(DOCKER_PASSWORD),)
	$(error Please define the DOCKER_PASSWORD environment variable)
endif

check_version:
ifeq ($(BUILD_VERSION),)
	$(error Please define the BUILD_VERSION environment variable)
endif

check_tf_bucket:
ifeq ($(TF_BUCKET_NAME),)
	$(error Please define the TF_BUCKET_NAME environment variable)
endif

build: check_version
	go build --ldflags '-X main.release=$(BUILD_VERSION) -linkmode external -extldflags "-static"' .

clean:
	rm -rf dacd_reference .terraform

docker: image docker_login push

docker_login: check_docker
	@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)

image: check_version build
	docker build --tag $(DOCKER_REPO)/dacd_reference:$(BUILD_VERSION) --build-arg BUILD_VERSION=$(BUILD_VERSION) .

infrastructure:
	scripts/infrastructure.sh

push: check_version
	docker push $(DOCKER_REPO)/dacd_reference:$(BUILD_VERSION)

release:
	scripts/release.sh

terraform: terraform_state terraform_modules
	terraform $(TF_CMD) $(TF_DIR)

terraform_modules:
	terraform get -update=true $(TF_DIR)

terraform_state: check_tf_bucket
	terraform remote config -backend=s3 \
		-backend-config="bucket=$(TF_BUCKET_NAME)" \
		-backend-config="key=$(S3_KEY_PREFIX)/dacd_reference/$(AWS_DEFAULT_REGION)"
