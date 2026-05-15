variable "name" {
  description = "Name of the security group (used for tagging and identification in AWS)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where this security group will be created. Ensures all resources stay in the same VPC."
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty. It must come from the VPC module output."
  }
}

variable "ssh_cidr" {
  description = "CIDR block allowed to access SSH (port 22). Example: 105.163.0.162/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "ssh_cidr must be a valid CIDR block (e.g. 105.163.0.162/32)."
  }
}

variable "app_port" {
  description = "Application port to allow inbound traffic (e.g. 80 for HTTP, 8080 for API)"
  type        = number

  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "enable_ssh" {
  description = "Whether to allow SSH access (port 22). Useful for disabling SSH in production environments."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Optional map of tags to apply to the security group"
  type        = map(string)
  default     = {}
}
