variable "name" {
  description = "Name tag for the VPC and related networking resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16). Defines the private IP range for the entire network."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR range (e.g. 10.0.0.0/16)."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet inside the VPC (e.g. 10.0.1.0/24). Must be within the VPC CIDR range."
  type        = string

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr must be a valid CIDR range (e.g. 10.0.1.0/24)."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC (required for EC2 public domain resolution)"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames so EC2 instances receive public DNS names"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Optional map of tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}
