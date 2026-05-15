variable "name" {
  description = "Server name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default = "t3.micro"
}

variable "port" {
  description = "Application port"
  type        = number
}

variable "ami_id" {
  description = "Ubuntu"
  type = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "key_name" {
  description = "SSH key pair"
  type        = string
}

variable "subnet_id" {
 description = "The Public Subnet" 
 type = string
}

variable "security_group_ids" {
 description = "Security Group" 
 type = list(string)
}

variable "app_tag_suffix" {
 description = "App Tag for Changes" 
 type    = string
 default = "v0"
}
