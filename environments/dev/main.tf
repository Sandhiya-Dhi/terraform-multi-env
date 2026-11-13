terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
 backend "s3" {}
}

provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  instance_name = var.instance_name
  environment   = var.environment
}
