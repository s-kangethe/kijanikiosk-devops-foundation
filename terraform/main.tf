provider "aws" {
  region = var.region
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name  = "virtualization-type"
    value = ["hvm"]
  }
}

locals {
  servers = {
    api = {
      instance_type = "t2.micro"
      port          = 3000
    }
    payments = {
      instance_type = "t2.micro"
      port          = 3001
    }
    logs = {
      instance_type = "t2.nano"
      port          = 5000
    }
  }
}

module "app_servers" {
  source   = "./modules/app_server"
  for_each = local.servers

  name          = each.key # "api", "payments", or "logs"
  instance_type = each.value.instance_type
  port          = each.value.port
  ami_id        = data.aws_ami.ubuntu.id
  environment   = var.environment
  key_name      = var.ssh_key_name
}

terraform {
  backend "s3" {
    bucket         = "kijanikiosk-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile        = true
  }
}
