#!/usr/bin/env bash

terraform_version="0.8.8"
terraform_download_url="https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
terraform_download_sha256="403d65b8a728b8dffcdd829262b57949bce9748b91f2e82dfd6d61692236b376"

curl -fsSL "${terraform_download_url}" -o terraform.zip \
	&& echo "${terraform_download_sha256}  terraform.zip" | sha256sum -c - \
	&& unzip -d /usr/local/bin terraform.zip \
	&& rm terraform.zip
