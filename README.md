# DevOps and Continuous Delivery - A Crash Course

This repository houses the reference project for my in-development course on the
fundamentals of DevOps and Continuous Delivery. It is a fully usable sample
project in its own right, but the course covers it in detail and students work
on deploying it within the class.

## What is the Course?

DevOps has changed much since the term was coined in the mid-late 2000's as a
methodology of applying software development principles and processes to systems
administration and automation, as has the cloud computing landscape that has
allowed this discipline to flourish. The development patterns that applications
are designed around, the platforms that host such applications, and the tooling
that works with those platforms have all matured to the point where developers
and systems engineers alike can adopt a very similar workflow for both
application development and infrastructure management.

This course is a 2-3 day bootcamp, designed to get you up to speed on DevOps,
both with the then and the now, and get you deploying a sample application using
modern development pipeline powered by Go, Terraform, and Travis CI. It will
give you the building blocks that you need to be able to understand how you can
treat both code and infrastructure as an application and subject them to the
same kind of continuous development and deployment lifecycle.

### Curriculum Topics Include:

 * An introduction to several important concepts of modern day DevOps, such as
   infrastructure as code, microservices and Service-Oriented Architecture
   (SOA), zero-downtime deployment strategies such as Blue/Green or Canary
   deploys, and the role of source control and CI/CD in it all.
 * An introduction to many industry-standard FOSS tools and services, including
   Git and GitHub (https://github.com/), Travis CI (https://travis-ci.org/),
   Docker (https://www.docker.com/), Terraform (https://terraform.io/).
 * An introduction to AWS (https://aws.amazon.com/), and deployment using EC2
   Auto Scaling.
 * How to create a simple deployment pipeline that handles rolling deploys,
   powered entirely by CI and Git tags.

### Learning Objectives

 * Get familiar with several popular Open Source services and tools in wide use
   in the industry at large, and use them to deliver a redundant and scalable
   microservice in AWS.
 * Learn how to use the same build automation strategies that drive your
   application to drive your infrastructure as well.
 * Be able to understand major Continuous Delivery strategies, and implement one
   of them to perform a rolling upgrade of your microservice.

### Code Details

The code in this repository houses a [Go][3] application that runs a simple web
server using the standard library (`net/http`) on port 8080. The web server
prints a "hello world" message with the viewer's IP address fetched either from
`X-Forwarded-For` if it exists, or the direct remote address otherwise. The
hostname and application version are also printed.

The build of this application is run with `make`, with the default target being to run
the tests in `main_test.go` (`go test -v .`, basically). Tests run off `master`
in Travis CI with every build.

Off tags, however, the job runs build and deploy tasks:

 * Release tags such as `v0.1.0` get built as a Docker image and pushed to
   Docker Hub - these images are super lightweight, using [Alpine Linux][4] as a
   base, and run around 5-15 MB for a full release.
 * Infrastructure build tags (those beginning with `infrastructure`) are
   deployed using Terraform, using a version of the container supplied through
   an automatically generated file.

Terraform creates infrastructure using Amazon AWS's [EC2 Auto Scaling][5]
service, on instances running [Rancher OS][6], which has configuration that
allows the instances to automatically receive the container we pushed to Docker
Hub.

Custom build scripting controls the release tagging process with `make release`
and `make infrastructure`, allowing control of the CI/CD pipeline entirely
through the command line, with source control and CI leaving a paper trail.

[3]: https://golang.org/
[4]: https://alpinelinux.org/
[5]: https://aws.amazon.com/autoscaling/
[6]: http://rancher.com/rancher-os/

### Fetching the Project

As this is a Go project, you need to have [Go][3] installed and a properly
working GOPATH. See [this page][7] for more details.

Once you have your development environment set up, run the following:

```
go get -d github.com/vancluever/dacd_reference
```

This will make the project available in
`$GOPATH/src/github.com/vancluever/dacd_reference`.

[7]: https://golang.org/doc/install

### Testing and Building the Project Locally

`make test` and `make build` will run tests and create the `dacd_reference`
binary, respectively. You can run the locally on your system by just running
`./dacd_reference` from the source directory - the program will bind to port
8080 from which you can access on localhost.

### Configuring Travis CI

In summary, the project should be fully ready to set up within Travis, either as
a fork or a duplicate. Simply enable the project within your Travis interface.

The following settings are necessary to ensure that all parts of the repository
work. Set these as environment variables within the Travis CI interface, **do
not add them to the `.travis.yml`**, as most of these are sensitive values:

 * `DOCKER_USERNAME` and `DOCKER_PASSWORD` for pushing the container to Docker
   Hub
 * `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to the AWS account that you
   want Terraform to connect to
 * `TF_BUCKET_NAME` to the AWS S3 bucket where Terraform will keep its state
   data
 * `TF_VAR_ssh_inbound_ip_address` and `TF_VAR_key_pair_name` to ensure that you
   are able to connect to the instances for troubleshooting.

### Releasing to Docker Hub

Once you have all of the requisite items set up in Travis, running `make
release` will run the release process, which entails creating a tag for the
release version and having Travis build it. You can see the results of the build
and release process within Travis itself, under the tag for the version you
released under.

Note that an account on [Docker Hub][8] is required for this process, so create
one if you don't have one already. After you are done, add the `DOCKER_USERNAME`
and `DOCKER_PASSWORD` environment variables to your Travis configuration (as
mentioned above), or the push will fail.

[8]: https://hub.docker.com/

### Deploying the Infrastructure with Terraform

This project is configured to deploy into AWS using [Terraform][9], using a S3
bucket to store the remote state. Create a bucket in your AWS account and ensure
that the AWS user that you will be using to deploy with has access to read and
write to and from the bucket.

[9]: https://www.terraform.io/

After this is complete, make sure the `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, `TF_BUCKET_NAME`, `TF_VAR_ssh_inbound_ip_address`, and
`TF_VAR_key_pair_name` variables are set in Travis (as mentioned above), and run
`make infrastructure`. This will write and push a infrastructure build tag
(example: `infrastructure#1-v0.1.0`), which will instruct Travis to deploy the
Terraform infrastructure. If all goes well it should take a little under 5
minutes for you to be able to access the new infrastructure.

The ELB hostname is given in the output, which you should be able to simply put
into your web browser to see the finished product.

#### Manual Deployment

The project can be manually deployed as well. You will need to export the
appropriate variables:
 
 * `DOCKER_USERNAME` and `DOCKER_PASSWORD` for pushing the container to Docker
   Hub. If you don't want to export these, and you have logged in on your Docker
   locally with `docker login`, there are separate steps documented below.
 * `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to the AWS account that you
   want Terraform to connect to, or have these in your `~/.aws/credentials` file
 * `TF_BUCKET_NAME` to the AWS S3 bucket where Terraform will keep its state
   data
 * `TF_VAR_ssh_inbound_ip_address` and `TF_VAR_key_pair_name` to ensure that you
   are able to connect to the instances for troubleshooting.

Once you have all of these variables exported, you can then run:

```
make docker
```

After the container is written for your latest version, take that version and
write out a `terraform/version.tf` file that looks like:

```
variable "build_version" {
  default = "0.1.0"
}
```

Replace `0.1.0` with whatever the version of the container is.

After this is done, you should be free to run:

```
make terraform
```

Which will fetch the Terraform state, any modules that are needed, and perform
the Terraform run.

Note that if you are not exporting your Docker credentials, `make docker` will
fail, as it attempts to log into Docker Hub via `docker login`. Instead, run:

```
make image # Creates the Docker image
make push  # Pushes the image to Docker Hub
```

#### Manually Destroying the Project

This project currently does not support destroying through Travis. This is by
design to prevent accidental automated deletion.

You can however, destroy the project by running the following commands from the
project directory:

```
TF_CMD=destroy make terraform
```

## Using the Toolbox

There is a toolbox/devkit included with this project that one can use to
bootstrap the whole project, with the tools configured for you on container
start, all contained in a Docker container.

To get it, you should be able to run the following command from any modern
version of Docker:

```
docker pull vancluever/dacd_toolbox
```

There are 2 alias files that may help you as well:

 * **OS X, Linux, or other bash:** Use
   `toolbox_dockerfile/dacd_toolbox_bash.alias`. Add this to your `.profile`
   or `.bashrc`.
 * **Windows 10**: Use
   `toolbox_dockerfile/dacd_toolbox_profile.ps1`. Add this to your
   `%UserProfile%\Documents\WindowsPowerShell\profile.ps1` file.

After doing either of these, working with a persistent container is as easy as
typing `dacd_toolbox`. The container will automatically configure the container
for you, and download a copy of this project using `go get -d`. Exiting the
container will not delete it and the existing container will be started the next
time your run `dacd_toolbox`.

## License

```
Copyright 2016, 2017 Chris Marchesi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
