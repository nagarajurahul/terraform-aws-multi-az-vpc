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
  version = "1.1.1"

  # Specify the AWS region for the VPC deployment
  region  = "us-east-1"
  
  # VPC CIDR block
  vpc_cidr = "10.0.0.0/16"

  # VPC Name (for tagging purposes)
  vpc_name = "my-multi-az-vpc"

  # Enable or disable NAT Gateway (optional)
  enable_nat_gateway = true

  # Number of devices per subnet (used to calculate subnet sizes)
  number_of_devices_per_subnet = 700
  
  # Enable IPv6 support (default is false)
  enable_ipv6 = true
  
  # Tags for resource identification and organization
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

## Important Notes

* **IPv6**: When enable_ipv6 is set to true, the module automatically assigns an IPv6 CIDR block to the VPC, and subnets will be allocated based on this.

* **NAT Gateway**: If you choose to use a NAT Gateway (enable_nat_gateway = true), this will be created in one of the public subnets, and a route will be configured for private subnets to route traffic through it.

* **Multi-AZ Deployment**: The module will automatically create subnets across all available AZs in the selected region. This ensures high availability and fault tolerance for your infrastructure.

## Contributions

This module is open-source. Contributions and improvements are welcome! If you encounter any issues or have suggestions, please feel free to open an issue or create a pull request.


## License

This module is licensed under the MIT License. See [LICENSE](./LICENSE) for more details.
