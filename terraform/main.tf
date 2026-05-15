data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  my_ip = chomp(data.http.my_ip.response_body)
}

provider "aws" {
  region = var.region
}


data "aws_ami" "ubuntu" {
   most_recent = true
   owners      = ["099720109477"] # Canonical (ubuntu)

   filter {
     name = "name"
     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
   }

   filter {
     name = "virtualization-type"
     values = ["hvm"]
   }  
}

module "vpc" {
  source = "./modules/vpc"

  name               = "kijani-vpc"
  cidr_block         = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "security_group" {
  source = "./modules/security_group"

  name   = "kijanikiosk-sg"
  vpc_id = module.vpc.vpc_id

  ssh_cidr = "${local.my_ip}/32"
  app_port = 80
}

module "app_servers" {
  source = "./modules/app_server"

  for_each = {
    api = {
      port          = 80
      instance_type = "t3.micro"
    }
    logs = {
      port          = 8080
      instance_type = "t3.micro"
    }
    payments = {
      port          = 9000
      instance_type = "t3.micro"
    }
  }

  name          = each.key
  instance_type = each.value.instance_type
  port          = each.value.port

  ami_id = data.aws_ami.ubuntu.id

  subnet_id          = module.vpc.public_subnet_id
  security_group_ids = [module.security_group.sg_id]

  environment = var.environment
  key_name    = var.ssh_key_name

  app_tag_suffix = var.app_tag_suffix
}
