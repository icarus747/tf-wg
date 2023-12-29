terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.0"
    }
  }
}

data "http" "myip" {
  url = "http://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.myip.response_body)
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical https://ubuntu.com/server/docs/cloud-images/amazon-ec2
}

resource "aws_key_pair" "mykey" {
  key_name   = var.my_aws_key
  public_key = module.tls.public_key_out
}

resource "aws_instance" "vpnserver" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.my_instance_type
  key_name                    = aws_key_pair.mykey.key_name
  vpc_security_group_ids      = [aws_security_group.security_group1.id]
  # user_data                   = file("post_install.sh")
  # user_data_replace_on_change = true
}

resource "aws_security_group" "security_group1" {
  ingress {
    cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    # cidr_blocks = ["67.141.161.98/32"]
    description = "SSH Ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    description = "WGUI Ingress"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
  }  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "WG Ingress"
    from_port   = 51821
    to_port     = 51821
    protocol    = "udp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "tls" {
  source = "./modules/tls"
}