# EKS Setup with Terraform  

## Overview  
This repository contains Terraform code to set up an Amazon EKS (Elastic Kubernetes Service) cluster using modular infrastructure components. The implementation follows the **DRY (Don't Repeat Yourself) principle** for efficient and reusable infrastructure code.  

## Modules Used  
The infrastructure is divided into separate modules:  
- **VPC** – Creates a Virtual Private Cloud (VPC) with subnets and networking components.  
- **SG (Security Groups)** – Manages security groups for controlling access.  
- **IAM** – Provisions necessary IAM roles and policies for EKS.  
- **EKS** – Deploys an EKS cluster with worker nodes.  
- **ALB (Application Load Balancer)** – Configures an ALB for managing external traffic.  
- **ECR (Elastic Container Registry)** – Creates a private container registry.  
- **ACM (AWS Certificate Manager)** – Manages SSL certificates for secure communication.  

## Infrastructure Creation  
The infrastructure is created using Terraform modules, ensuring:  
✅ **Modularity** – Each component is independently manageable.  
✅ **Reusability** – Common patterns are applied across environments.  
✅ **Scalability** – Easily extendable for future needs.  

## Usage  
1. Clone the repository.  
2. Configure Terraform backend and variables.  
3. Apply the Terraform code to provision resources.  
