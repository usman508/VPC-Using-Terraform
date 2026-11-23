# VPC for Lambda → RDS

Terraform that provisions a production-style AWS network where Lambda functions
in private subnets can reach an RDS database in isolated subnets. Nothing else
can reach the database.

## Architecture

```
                         Internet
                            │
                    ┌───────┴────────┐
                    │ Internet GW    │
┌───────────────────┴────────────────┴───────────────────────┐
│ VPC 10.0.0.0/16                                            │
│                                                            │
│  Public subnets  10.0.0.0/24, 10.0.1.0/24   ── NAT GW      │
│        ▲ 0.0.0.0/0 → IGW                                   │
│        │                                                   │
│  Private subnets 10.0.10.0/24, 10.0.11.0/24 ── Lambda ENIs │
│        │ 0.0.0.0/0 → NAT          sg-lambda                │
│        │                              │ tcp/db_port        │
│        ▼                              ▼                    │
│  Database subnets 10.0.20.0/24, 10.0.21.0/24 ── RDS        │
│        local route only (no internet)  sg-rds              │
└────────────────────────────────────────────────────────────┘
```

| Tier     | Route table                        | Purpose                           |
|----------|------------------------------------|-----------------------------------|
| public   | `0.0.0.0/0 → IGW`                  | NAT gateways                      |
| private  | `0.0.0.0/0 → NAT` (one RT per AZ)  | Lambda (can call AWS APIs/internet) |
| database | local only                         | RDS (no internet in or out)       |

**Security groups (least privilege):**

- `lambda-sg` egress → `rds-sg` on `db_port`; egress → `443` for AWS APIs (Secrets Manager, etc.)
- `rds-sg` ingress ← `lambda-sg` on `db_port` only; no egress
- The VPC default security group is stripped of all rules

## Layout

```
.
├── main.tf                     # Composes the modules
├── variables.tf / outputs.tf
├── providers.tf / versions.tf
├── terraform.tfvars.example
└── modules
    ├── vpc                     # VPC, subnets, IGW, NAT, route tables, DB subnet group, flow logs
    └── security-groups         # Lambda + RDS security groups and rules
```

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit values
terraform init
terraform plan
terraform apply
```

## Wiring Lambda and RDS

Pass the outputs to your Lambda and RDS resources (same stack, or via
`terraform_remote_state`):

```hcl
resource "aws_lambda_function" "app" {
  # ...
  vpc_config {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.security_groups.lambda_security_group_id]
  }
}

# The Lambda execution role also needs ENI permissions:
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_db_instance" "db" {
  # ...
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  publicly_accessible    = false
}
```

## Key inputs

| Name                 | Default        | Notes                                              |
|----------------------|----------------|----------------------------------------------------|
| `project`            | —              | Required. Lowercase, used in names/tags            |
| `environment`        | —              | Required. `dev`, `staging` or `prod`               |
| `vpc_cidr`           | `10.0.0.0/16`  | Subnets are auto-carved as `/24`s                  |
| `az_count`           | `2`            | 2–6; RDS needs at least 2                          |
| `enable_nat_gateway` | `true`         | Disable if Lambda only needs RDS (saves cost)      |
| `single_nat_gateway` | `true`         | Set `false` in prod for one NAT per AZ             |
| `enable_flow_logs`   | `true`         | VPC flow logs → CloudWatch (30-day retention)      |
| `db_port`            | `5432`         | `3306` for MySQL/MariaDB                           |

## Cost notes

NAT gateways are billed hourly plus per-GB. If Lambda only talks to RDS and
needs no internet/AWS API access, set `enable_nat_gateway = false`. To reach
Secrets Manager without a NAT, add an interface VPC endpoint instead.
