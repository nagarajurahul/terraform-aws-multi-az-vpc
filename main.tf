provider "aws"{
    region = var.region
}

data "aws_regions" "current"{

}

# Pull avialable azs dynamically from aws for current region
data "aws_availability_zones" "available" {
  state = "available"
}

locals{
    az_count = length(data.aws_availability_zones.available.names)
}

# Create aws vpc resource
resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    tags = {
       "Name" = "multi-az-vpc" 
    }
}

# Maximum number of supported devices per subnet are 2041
# Minimum is 249

# Calculate the subnet mask
locals {
    usable_ips = var.number_of_devices_per_subnet + 5 # Add 5 for reserved IPs by AWS

    subnet_mask = (
    local.usable_ips <= 254 ? 24 : # 256 total IPs, 254 usable
    local.usable_ips <= 510 ? 23 : # 512 total IPs, 510 usable
    local.usable_ips <= 1022 ? 22 : 21 # 1024 total IPs, 1022 usable
  )
}

# Generate cidrs for public and private subnets
locals{
  private_subnet_cidrs = [
    for i in range(data.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_mask - 16, i + 1)
  ]

  public_subnet_cidrs = [
    for i in range(data.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_mask - 16, i + data.az_count + 1)
  ]  
}


# resource "aws_subnet" "private"{
#     vpc_id = aws_vpc.main.id
#     # cidr_block = 
# }