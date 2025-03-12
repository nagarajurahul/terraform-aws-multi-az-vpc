# terraform-aws-multi-az-vpc
Public repo to deploy multi az vpc in AWS

## Multi-AZ VPC Terraform Module

### Overview

This Terraform module creates a highly available, Multi-AZ Virtual Private Cloud (VPC) in AWS. It provisions public and private subnets, an Internet Gateway, and an optional NAT Gateway for secure outbound traffic from private subnets. 

This module is designed for scalability, security, and best cloud architecture practices.

## Features

**Multi-AZ Deployment**: Dynamically provisions subnets across all available Availability Zones (AZs) in the selected AWS region.

**Public & Private Subnets**: Automatically calculates subnet CIDRs based on the number of devices per subnet.

**Highly Available NAT Gateway (Optional)**: Supports single or no NAT Gateway for cost efficiency.

**Tagging Support**: Apply common tags to all resources.


## Usage

```hcl
module "multi_az_vpc" {
  source  = "github.com/your-github-username/multi-az-vpc"
  region  = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my-multi-az-vpc"
  enable_nat_gateway = true
  tags = { "Project" = "CloudInfra" }
}
```

## Deployment Instructions

1. Initialize Terraform

```
terraform init
```

2. Plan the infrastructure

```
terraform plan
```

3. Apply the changes

```
terraform apply -auto-approve
```

4. Destroy if needed

```
terraform destroy -auto-approve
```
