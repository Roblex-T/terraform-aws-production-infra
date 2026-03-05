variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "rob-infra"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Use regular AZs only (NOT local zones)
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# Must match count(azs)
variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

# DB subnets in 2 AZs (required for Multi-AZ)
variable "database_subnets" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}

# App / ASG
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_cidr" {
  type        = string
  description = "Your IP /32 for SSH (recommended). Example: 203.0.113.10/32"
  default     = "0.0.0.0/0"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

# RDS
variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "admin"
}

# DO NOT commit the real password in GitHub.
variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}