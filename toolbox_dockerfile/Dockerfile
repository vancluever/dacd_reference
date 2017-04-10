FROM ubuntu:16.04

# Locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Golang
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
    curl \
    ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.7.5
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 2e4dd6c44f0693bef4e7b46cc701513d74c3cc44f2419bf519d7868b12931ac3

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH"

# Python

RUN apt-get update && apt-get install -y --no-install-recommends \
		python \
		python-pip \
		python-setuptools \
	&& rm -rf /var/lib/apt/lists/*

# aws-cli

RUN pip install awscli

# git and build-essential
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
    ssh \
		build-essential \
	&& rm -rf /var/lib/apt/lists/*

# unzip
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
	&& rm -rf /var/lib/apt/lists/*

# Terraform

ENV TERRAFORM_VERSION 0.8.8
ENV TERRAFORM_DOWNLOAD_URL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV TERRAFORM_DOWNLOAD_SHA256 403d65b8a728b8dffcdd829262b57949bce9748b91f2e82dfd6d61692236b376

RUN curl -fsSL "$TERRAFORM_DOWNLOAD_URL" -o terraform.zip \
	&& echo "$TERRAFORM_DOWNLOAD_SHA256  terraform.zip" | sha256sum -c - \
	&& unzip -d /usr/local/bin terraform.zip \
	&& rm terraform.zip

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT /usr/local/bin/entrypoint.sh

