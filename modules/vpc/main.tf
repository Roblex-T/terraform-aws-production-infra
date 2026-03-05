module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "${var.project_name}-vpc"
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # DB in private subnets (separate tier) across 2 AZs
  database_subnets                 = var.database_subnets
  create_database_subnet_group     = true
  create_database_subnet_route_table = true

  # NAT is needed if private instances must reach the internet (yum, updates, etc.)
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project   = var.project_name
    Terraform = "true"
  }
}