variable "region" {
  description = "AWS region where all resources will be deployed for your project. Controls where The physical location of infrastructure and available resources in AWS lives"
  type        = string
  default     = "eu-west-1"
}

variable "server_name" {
  description = "Name identifier for the server instance used for tagging and resource identification"
  type        = string
  default     = "kijanikiosk-server"
}

variable "instance_type" {
  description = "EC2 instance size defining CPU, memory and performance capacity"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Application port number the service will listen on inside the instance"
  type        = number
  default     = 8080
}

variable "environment" {
  description = "Deployment environment label such as dev, staging or production"
  type        = string
  default     = "staging"
}

variable "ssh_key_name" {
  description = "AWS EC2 Key Pair name used for SSH access to the instance"
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "app_tag_suffix" {
  description = "Suffix used for demo run tagging (RUN1 vs RUN2)"
  type        = string
  default     = "v0"
}
