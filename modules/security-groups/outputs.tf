output "lambda_security_group_id" {
  description = "Security group ID to attach to Lambda functions (vpc_config.security_group_ids)."
  value       = aws_security_group.lambda.id
}

output "rds_security_group_id" {
  description = "Security group ID to attach to RDS instances (vpc_security_group_ids)."
  value       = aws_security_group.rds.id
}
