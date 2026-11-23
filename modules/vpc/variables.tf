variable "name" {
  description = "Name prefix applied to every resource created by this module."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR, e.g. 10.0.0.0/16."
  }
}

variable "azs" {
  description = "Availability Zones to spread subnets across. Use at least two for RDS."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two Availability Zones are required (RDS subnet groups need two)."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (one per AZ). Hosts NAT gateways."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private application subnets (one per AZ). Lambda ENIs live here."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDRs for isolated database subnets (one per AZ). No route to the internet."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) so private subnets (Lambda) can reach the internet / AWS public APIs."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway (cheaper) instead of one per AZ (highly available)."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Retention period (days) for the VPC flow log group."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
