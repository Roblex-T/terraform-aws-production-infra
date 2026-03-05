module "vpc" {
  source = "./modules/vpc"

  project_name     = var.project_name
  cidr             = var.vpc_cidr
  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
}

module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  ssh_cidr           = var.ssh_cidr
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
}

module "rds" {
  source = "./modules/rds"

  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  db_subnet_ids       = module.vpc.database_subnet_ids
  app_sg_id           = module.ec2.app_sg_id
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  db_instance_class   = var.db_instance_class
}