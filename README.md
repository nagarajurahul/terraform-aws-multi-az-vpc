## Multi-AZ VPC Terraform Module

### Overview

This Terraform module creates a highly available, Multi-AZ Virtual Private Cloud (VPC) in AWS. 

It provisions public and private subnets, an Internet Gateway, and an optional NAT Gateway for secure outbound traffic from private subnets. 

New - Additionally, IPv6 support is included for modern network requirements.

This module is designed for scalability, security, and best cloud architecture practices.

## Features

**DNS Support for VPC**: Automatically enables DNS support and hostnames within the VPC.

**Multi-AZ Deployment**: Dynamically provisions subnets across all available Availability Zones (AZs) in the selected AWS region.

**Public & Private Subnets**: Efficiently calculates subnet CIDRs based on the desired number of devices per subnet.

**IPv6 Support**: Adds IPv6 addressing to both the VPC and subnets, ensuring scalability and future-proofing for your infrastructure.

**Highly Available NAT Gateway (Optional)**: Includes support for a single or multiple NAT Gateways for secure, cost-effective internet access from private subnets.

**Tagging Support**: Ensures consistent resource tagging across all provisioned resources, making it easy to manage and identify resources in your environment.

## Architecture

This module provisions the following AWS resources:

* VPC with customizable CIDR block

* Public and Private Subnets across multiple Availability Zones (AZs)

* Internet Gateway for public access

* NAT Gateway (optional, for private subnet outbound traffic)

* Route Tables for routing configurations

* IPv6 CIDR blocks (if enabled)

## Usage

```hcl
module "multi_az_vpc" {
  source  = "nagarajurahul/multi-az-vpc/aws"
  version = "1.0.2"

  # Or use this as a source with commenting the version line
  # source = "github.com/nagarajurahul/terraform-aws-multi-az-vpc"
  
  region  = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my-multi-az-vpc"
  enable_nat_gateway = true

  number_of_devices_per_subnet=700
  enable_ipv6 = true

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
