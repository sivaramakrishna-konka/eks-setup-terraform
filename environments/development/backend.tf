terraform {
  backend "s3" {
    bucket = "infra-tf-konkas-tech"
    key = "eks-setup-terraform/development/terraform.tfstate"
    region = "us-east-1"
  }
}