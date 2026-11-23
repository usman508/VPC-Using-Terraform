################################################################################
# Security groups
#
# Rules are declared as standalone resources (not inline blocks) so the
# Lambda <-> RDS cross-references don't create a dependency cycle.
# Terraform removes AWS's default allow-all egress rule, so only the rules
# below are in effect (least privilege).
################################################################################

resource "aws_security_group" "lambda" {
  name_prefix = "${var.name}-lambda-"
  description = "Lambda functions that connect to RDS"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-lambda-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  description = "RDS instances reachable only from Lambda"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Lambda rules
################################################################################

resource "aws_vpc_security_group_egress_rule" "lambda_to_rds" {
  security_group_id            = aws_security_group.lambda.id
  description                  = "Database traffic to RDS"
  referenced_security_group_id = aws_security_group.rds.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "lambda_https" {
  for_each = var.allow_lambda_https_egress ? toset(var.lambda_https_egress_cidrs) : toset([])

  security_group_id = aws_security_group.lambda.id
  description       = "HTTPS to AWS APIs (Secrets Manager, SSM, KMS, etc.)"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  tags = var.tags
}

################################################################################
# RDS rules
################################################################################

resource "aws_vpc_security_group_ingress_rule" "rds_from_lambda" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Database traffic from Lambda"
  referenced_security_group_id = aws_security_group.lambda.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port

  tags = var.tags
}
