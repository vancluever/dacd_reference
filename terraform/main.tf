// Copyright 2017 Chris Marchesi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// The key pair to launch the instances with.
variable "key_pair_name" {
  type    = "string"
  default = ""
}

// The IP address to allow SSH inbound from.
variable "ssh_inbound_ip_address" {
  type    = "string"
  default = ""
}

// The project path.
variable "project_path" {
  type    = "string"
  default = "vancluever/dacd_reference"
}

// The IP space for the VPC.
variable "vpc_network_address" {
  type    = "string"
  default = "10.0.0.0/24"
}

// The IP space for the public subnets within the VPC.
variable "public_subnet_addresses" {
  type    = "list"
  default = ["10.0.0.0/25", "10.0.0.128/25"]
}

// instance_service_data creates cloud-config parts that we can roll into user
// data to load the artifact as a container thru Rancher.
module "instance_service_data" {
  source       = "github.com/vancluever/terraform_rancher_service?ref=v0.1.0"
  image_name   = "${var.project_path}:${var.build_version}"
  network_mode = "host"
  service_name = "${element(split("/", var.project_path), 1)}"
}

// instance_user_data provides the user data that we will load into our launched
// RancherOS instances.
module "instance_user_data" {
  source                  = "github.com/vancluever/terraform_rancher_user_data?ref=v0.1.0"
  rancher_service_entries = ["${module.instance_service_data.rancher_service_data}"]
}

// vpc creates the VPC that will get created for our project.
module "vpc" {
  source                  = "github.com/paybyphone/terraform_aws_vpc?ref=v0.1.0"
  project_path            = "${var.project_path}"
  public_subnet_addresses = ["${var.public_subnet_addresses}"]
  vpc_network_address     = "${var.vpc_network_address}"
}

// alb creates the ALB that will get created for our project.
module "alb" {
  source              = "github.com/paybyphone/terraform_aws_alb?ref=v0.1.0"
  listener_subnet_ids = ["${module.vpc.public_subnet_ids}"]
  project_path        = "${var.project_path}"
}

// autoscaling_group creates the autoscaling group that will get created for
// our project.
//
// The ALB is also attached to this autoscaling group with the default /*
// path pattern.
module "autoscaling_group" {
  source                      = "github.com/paybyphone/terraform_aws_asg?ref=v0.2.1"
  alb_listener_arn            = "${module.alb.alb_listener_arn}"
  alb_service_port            = "8080"
  associate_public_ip_address = "true"
  enable_alb                  = "true"
  image_filter_type           = "name"
  image_filter_value          = "rancheros-v*-hvm-1"
  image_owner                 = "605812595337"
  key_pair_name               = "${var.key_pair_name}"
  project_path                = "${var.project_path}"
  subnet_ids                  = ["${module.vpc.public_subnet_ids}"]
  user_data                   = "${module.instance_user_data.rendered}"
}

// autoscaling_group_ssh_security_group_rule allows SSH into the instances from
// a specific IP address.
resource "aws_security_group_rule" "autoscaling_group_ssh_security_group_rule" {
  count             = "${var.ssh_inbound_ip_address != "" ? 1 : 0 }"
  cidr_blocks       = ["${var.ssh_inbound_ip_address}"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${module.autoscaling_group.instance_security_group_id}"
  to_port           = 22
  type              = "ingress"
}

output "alb_hostname" {
  value = "${module.alb.alb_dns_name}"
}

output "alb_security_group_id" {
  value = "${module.alb.alb_security_group_id}"
}

output "asg_instance_security_group_id" {
  value = "${module.autoscaling_group.instance_security_group_id}"
}
