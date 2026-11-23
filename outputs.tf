output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "availability_zones" {
  description = "Availability Zones in use."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs - use for aws_lambda_function.vpc_config.subnet_ids."
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Isolated database subnet IDs."
  value       = module.vpc.database_subnet_ids
}

output "db_subnet_group_name" {
  description = "DB subnet group - use for aws_db_instance.db_subnet_group_name."
  value       = module.vpc.db_subnet_group_name
}

output "lambda_security_group_id" {
  description = "Use for aws_lambda_function.vpc_config.security_group_ids."
  value       = module.security_groups.lambda_security_group_id
}

output "rds_security_group_id" {
  description = "Use for aws_db_instance.vpc_security_group_ids."
  value       = module.security_groups.rds_security_group_id
}

output "nat_gateway_public_ips" {
  description = "Egress IPs used by Lambda when calling external services."
  value       = module.vpc.nat_gateway_public_ips
}
