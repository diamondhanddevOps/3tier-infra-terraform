packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
      }
    }
  }
 source "amazon-ebs" "basic-ami" {
  ami_name = "Nodejs-ami"
  instance_type = "t3a.micro"
  ssh_username  =  "ubuntu"
  source_ami = "ami-0530ca8899fac469f"
  region         = "us-west-2"
  iam_instance_profile = "CodeDeploynodejsAppEC2"
}
build {

  sources = ["source.amazon-ebs.basic-ami"]
  provisioner "shell" {
    script       = "nodejs.sh"
    pause_before = "10s"
    timeout      = "10s"
}
    }