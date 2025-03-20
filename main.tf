terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "aws" {
  region = var.region

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]    
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
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.my_instance_type
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.security_group1.id]
  # user_data                   = file("post_install.sh")
  # user_data_replace_on_change = true

  provisioner "local-exec" {
    command = "terraform output -raw private_key > mykey.pem && chmod 600 mykey.pem"
  }
}

resource "aws_ec2_instance_state" "vpnserver" {
  instance_id = aws_instance.vpnserver.id
  state       = "stopped"
  # state       = "running"
}

resource "cloudflare_record" "example" {
  zone_id     = var.cloudflare_zone_id
  name        = "aws"
  content       = aws_instance.vpnserver.public_dns
  type        = "CNAME"
  ttl         = 300
}

resource "aws_security_group" "security_group1" {
  ingress {
    cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    description = "SSH Ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "NGINX"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
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
