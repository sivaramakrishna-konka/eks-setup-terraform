# VPC
module "eks_vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  project_name         = var.project_name
  azs                  = var.azs
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  db_subnet_cidr       = var.db_subnet_cidr
  vpc_cidr             = var.vpc_cidr
  common_tags          = var.common_tags
  enable_nat           = var.enable_nat
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
}