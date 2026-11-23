variable "name" {
  description = "Name prefix applied to every resource created by this module."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security groups."
  type        = string
}

variable "db_port" {
  description = "Port the database listens on (5432 PostgreSQL, 3306 MySQL/MariaDB)."
  type        = number
  default     = 5432

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "db_port must be a valid TCP port (1-65535)."
  }
}

variable "allow_lambda_https_egress" {
  description = "Allow Lambda outbound HTTPS (443) to reach AWS APIs such as Secrets Manager, SSM or KMS."
  type        = bool
  default     = true
}

variable "lambda_https_egress_cidrs" {
  description = "Destination CIDRs for Lambda HTTPS egress."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
