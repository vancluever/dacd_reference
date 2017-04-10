#!/bin/bash

go_src_path="/go/src"
ref_project_path="github.com/vancluever/dacd_reference"

# message prints text with a color, redirected to stderr in the event of
# warning or error messages.
message() {
  declare -A __colors=(
    ["error"]="31"   # red
    ["warning"]="33" # yellow
    ["begin"]="32"   # green
    ["ok"]="32"      # green
    ["info"]="1"     # bold
    ["reset"]="0"    # here just to note reset code
  )
  local __type="$1"
  local __message="$2"
  if [ -z "${__colors[$__type]}" ]; then
    __type="info"
  fi
  if [[ ! "${__type}" =~ ^(warning|error)$ ]]; then
    echo -e "\e[${__colors[$__type]}m${__message}\e[0m" 1>&2
  else
    echo -e "\e[${__colors[$__type]}m${__message}\e[0m"
  fi
}

# configure_git configures git for you.
configure_git() {
  local git_user=""
  local git_email=""
  message begin "Configuring Git."
  read -r -p "Enter your name: " git_user
  read -r -p "Enter your email address: " git_email
  git config --global user.name "${git_user}"
  git config --global user.email "${git_email}"
  message ok "Git configured successfully."
}

# check_git checks to make sure that git is configured - if it's not, it
# configures it for you.
check_git() {
  if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
    message warning "Git config not complete or not configured, configuring."
    configure_git
  else
    message ok "Git config looks OK."
  fi
}

# check_aws_config checks to make sure that the AWS config is ok - if it's not,
# run "aws configure".
check_aws_config() {
  if ! [ -f "${HOME}/.aws/config" ] || ! [ -f "${HOME}/.aws/credentials" ]; then
    message warning "AWS config not complete or not configured, configuring."
    aws configure
    message ok "AWS config completed."
  else
    message ok "AWS config looks OK."
  fi
}

# create_ssh_key creates an SSH key and prints the public key on stdout.
create_ssh_key() {
  message begin "Creating SSH key."
  ssh-keygen -b 4096
  message warning "Your public key is:"
  message warning "$(cat "${HOME}/.ssh/id_rsa.pub")"
  message warning "Save this SSH key in your GitHub profile."
  message warning "You can get the key again at any time by checking the ${HOME}/.ssh/id_rsa.pub file."

  message ok "SSH key creation completed."
}

# check_ssh_key checks to see if there's an SSH key in the container already
# and adds one if you need it.
check_ssh_key() {
  if ! [ -f "${HOME}/.ssh/id_rsa" ]; then
    message warning "SSH key missing - generating a new one."
    create_ssh_key
  else
    message ok "SSH key is present."
  fi
}

# check_ssh_config checks to see if $HOME/.ssh/config is present, and if not,
# writes it out.  currently the only config needed is AddKeysToAgent.
check_ssh_config() {
  if ! [ -f "${HOME}/.ssh/config" ]; then
    echo "AddKeysToAgent yes" >> "${HOME}/.ssh/config"
    message warning "Wrote out SSH config to ${HOME}/.ssh/config."
  else
    message ok "SSH config is present."
  fi
}

# check_ref_project ensures that the reference project has been checked out
# into the $GOPATH, and if missing will install it.
check_ref_project() {
  if ! [ -d "${go_src_path}/${ref_project_path}" ]; then
    message warning "dacd_reference project not present, downloading with go get -d..."
    go get -d "${ref_project_path}"
    message ok "Download successful."
  else
    message ok "dacd_reference reference project present."
  fi
}

message begin "==> DACD toolbox container starting <=="
check_git
check_ssh_key
check_ssh_config
check_aws_config
check_ref_project

message begin "Starting bash shell in ${go_src_path}/${ref_project_path}"
cd "${go_src_path}/${ref_project_path}" && /usr/bin/ssh-agent /bin/bash
exit $?
