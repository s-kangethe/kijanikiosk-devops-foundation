variable "region" {
  description = "AWS region where all resources will be deployed. Controls where The physical location of infrastructure and available resources in AWS lives"
}
variable "name" {
  description = "Name identifier for the server instance used for tagging and resource identification"
}
variable "instance_type" {
  description = "EC2 instance size defining CPU, memory and performance capacity"
}
variable "port" {
  description = "Application port number the service will listen on inside the instance"
}
variable "amid_id" {
  description = "Amazon Machine ID used as the base OS for the EC2 instance"
}
variable "environment" {
  description = "Deployment environment label such as dev, staging or production used for tagging and isolation"
}
variable "key_name" {
  description = "AWS EC2 Key Pair name used for SSH access to the instance"
}
