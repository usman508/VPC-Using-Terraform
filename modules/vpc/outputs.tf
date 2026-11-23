output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (use for Lambda vpc_config)."
  value       = [for az in var.azs : aws_subnet.private[az].id]
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets."
  value       = [for az in var.azs : aws_subnet.database[az].id]
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = aws_db_subnet_group.this.name
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables (one per AZ)."
  value       = [for az in var.azs : aws_route_table.private[az].id]
}

output "database_route_table_id" {
  description = "ID of the database route table."
  value       = aws_route_table.database.id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT gateways (useful for allow-listing Lambda egress)."
  value       = [for eip in aws_eip.nat : eip.public_ip]
}
