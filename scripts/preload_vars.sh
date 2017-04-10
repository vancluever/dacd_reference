#!/usr/bin/env bash

# preload_vars.sh prompts you for environment variables that need to be set to
# ensure the build runs properly. Note that we don't do any sanity checking -
# if your build fails, re-run this script to attempt to add the correct vars.

# fetch_ipaddr uses curl to fetch your IP address from https://api.ipify.org/.
fetch_ipaddr() {
  local __ipaddr=""
  if ! __ipaddr=$(curl --silent https://api.ipify.org/);  then
		exit $?
	fi
  echo "${__ipaddr}"
}

docker_username=""
docker_password=""
tf_bucket_name=""
ssh_inbound_ip=""
default_inbound_ip=""
if ! default_inbound_ip=$(fetch_ipaddr); then
  echo -e "\nError checking IP address with https://api.ipify.org/ - exiting."
  echo "Try running curl -V https://api.ipify.org/ if the error was not displayed above."
  exit 1
fi
key_pair_name=""

read -r -p "Enter your Docker username: " docker_username
read -r -s -p "Enter your Docker password: " docker_password
# newline is needed here because it is not echoed on slient input
echo
read -r -p "Enter the address of the Terraform state bucket: " tf_bucket_name
read -r -p "Enter the IP address to allow for SSH (default ${default_inbound_ip}): " ssh_inbound_ip
read -r -p "Enter the key pair name to launch instances with: " key_pair_name

export DOCKER_USERNAME="${docker_username}"
export DOCKER_PASSWORD="${docker_password}"
export TF_BUCKET_NAME="${tf_bucket_name}"
if [ -n "${ssh_inbound_ip}" ]; then
	export TF_VAR_ssh_inbound_ip_address="${ssh_inbound_ip}/32"
else
	export TF_VAR_ssh_inbound_ip_address="${default_inbound_ip}/32"
fi
export TF_VAR_key_pair_name="${key_pair_name}"
