data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name = "${var.project}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # /24 subnets carved from the VPC CIDR:
  #   public   -> x.x.0-9.0/24
  #   private  -> x.x.10-19.0/24
  #   database -> x.x.20-29.0/24
  public_subnet_cidrs   = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  database_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 20)]

  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

module "vpc" {
  source = "./modules/vpc"

  name                  = local.name
  cidr_block            = var.vpc_cidr
  azs                   = local.azs
  public_subnet_cidrs   = local.public_subnet_cidrs
  private_subnet_cidrs  = local.private_subnet_cidrs
  database_subnet_cidrs = local.database_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

module "security_groups" {
  source = "./modules/security-groups"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  db_port = var.db_port
}
