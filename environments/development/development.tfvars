# Common variables
region = "us-east-1"
environment = "development"
project_name = "eks-setup-terraform"
vpc_common_tags = {
  "Terraform" = "true"
  "Environment" = "development"
  "Project" = "eks-setup-terraform"
  "Owner"       = "Konka"
}
vpc_cidr = "10.1.0.0/16"
azs = ["us-east-1a", "us-east-1b"]
public_subnet_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidr = ["10.1.10.0/24", "10.1.20.0/24"]
db_subnet_cidr = ["10.1.30.0/24", "10.1.40.0/24"]
enable_nat = false
enable_vpc_flow_logs = false
