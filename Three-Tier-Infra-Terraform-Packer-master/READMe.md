# Three-Tier-Infra as a code

This repo is functionality complete — PRs and issues welcome!

# Getting started

To get the infra running on aws:

- Clone this repo
- change directory to stg/terraform
- `terraform init` to install all required module source
- `terraform plan and apply` to see the resources to be create and to create infra on AWS
- To build image for nodejs backend
- `packer init`
- `packer build nodejsAmi.pkr.hcl`


# Code Overview

## Dependencies

- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) - To install terraform.
- [packer](https://www.packer.io/) - To install packer.
- [AWS cli](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-install.html) - to install aws cli only if you are configuring AWS credentials.


## Application Structure

- `terraform/` - This folder contains terraform code to create thee-tier-infra in AWS.
- `packer/` - This folder contains the code to create image for the backend i.e node js application.


## Authentication

Install AWS cli and configure aws credentials.
You can also export secret and access key to .env file and map the variables in `provider.tf`

