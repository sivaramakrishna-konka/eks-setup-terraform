#!/bin/bash

set -e

echo "Initializing Terraform..."
terraform init -backend-config=environments/development/backend.tfvars

echo "Formatting Terraform files..."
terraform fmt

echo "Validating Terraform configuration..."
terraform validate


echo "Generating Terraform plan..."
terraform plan -var-file=environments/development/development.tfvars


read -p "Do you want to proceed with 'terraform apply'? (yes/no): " choice
case "$choice" in 
  yes|y ) 
    echo "Applying Terraform changes..."
    terraform apply -var-file=environments/development/development.tfvars
    ;;
  no|n ) 
    echo "Terraform apply aborted by user."
    exit 0
    ;;
  * ) 
    echo "Invalid input. Please enter 'yes' or 'no'."
    exit 1
    ;;
esac
