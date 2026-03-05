output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}