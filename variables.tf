variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name, used in resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,24}$", var.project))
    error_message = "project must be 2-24 chars of lowercase letters, digits or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC. Subnets are carved out as /24s automatically."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use (minimum 2 for RDS)."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 6
    error_message = "az_count must be between 2 and 6."
  }
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) so Lambda can reach the internet / public AWS endpoints."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (lower cost) instead of one per AZ (higher availability)."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "db_port" {
  description = "Database port Lambda connects to (5432 PostgreSQL, 3306 MySQL)."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Extra tags merged into the default tags on every resource."
  type        = map(string)
  default     = {}
}
