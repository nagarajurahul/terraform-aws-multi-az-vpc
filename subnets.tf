# # Pull available azs dynamically from aws for the current region
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# locals{
#     az_count = length(data.aws_availability_zones.available.names)
# }

# Maximum number of devices allocated per subnet will be 2043
# Minimum number of devices allocated will be 251

# Calculate the subnet mask
locals {
    usable_ips = var.number_of_required_ips_per_subnet + 5 # Add 5 for reserved IPs by AWS

    subnet_mask = (
    local.usable_ips <= 256 ? 24 : # 256 total IPs, 251 usable
    local.usable_ips <= 512 ? 23 : # 512 total IPs, 507 usable
    local.usable_ips <= 1024 ? 22 : 21 # 1024 total IPs, 1019 usable
    )
    
    public_subnet_mask  = 24
    private_subnet_mask = local.subnet_mask

    public_newbits  = local.public_subnet_mask - 16
    private_newbits = local.private_subnet_mask - 16
}

locals {
  private_azs = [for az,value in var.availability_zones: value.availability_zone if value.private_subnet==true]
  private_azs_with_nat = [for az,value in var.availability_zones: value.availability_zone if value.enable_nat_gateway==true]
  public_azs  = [for az,value in var.availability_zones: value.availability_zone if value.public_subnet==true]
}

# Generate cidrs for public and private subnets
locals{
  private_subnet_cidrs = {
    for i,value in local.private_azs : value => cidrsubnet(var.vpc_cidr, local.private_newbits, i + 1)
  }

  public_subnet_cidrs = {
    for i,value in local.public_azs :  value => cidrsubnet(var.vpc_cidr, local.public_newbits, i + length(local.private_azs) + 1)
  }  
}

# IPv6 CIDR Block for VPC
# resource "aws_vpc_ipv6_cidr_block_association" "ipv6" {
#   count  = var.enable_ipv6 ? 1 : 0
#   vpc_id = aws_vpc.main.id
# }

# # Generate CIDRs for IPv6 Subnets
# locals {
#   private_subnet_ipv6_cidrs = var.enable_ipv6 ? [
#     # for i in range(local.az_count) : cidrsubnet(aws_vpc_ipv6_cidr_block_association.ipv6[0].ipv6_cidr_block, 8, i)
#     for i in range(local.az_count) : cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, i)

#   ] : []

#   public_subnet_ipv6_cidrs = var.enable_ipv6 ? [
#     for i in range(local.az_count) : cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, i + local.az_count)
#   ] : []
# }


resource "aws_subnet" "private"{
    for_each = local.private_subnet_cidrs

    vpc_id = aws_vpc.main.id
    cidr_block = each.value
    availability_zone = each.key

    # assign_ipv6_address_on_creation = var.enable_ipv6
    # ipv6_cidr_block = var.enable_ipv6 ? local.private_subnet_ipv6_cidrs[count.index] : null

    tags = merge(
      var.tags, 
      {
        Name = "${var.vpc_name}-${each.key}-private"
      }
    )

    lifecycle {
      # Enable this as true while implementing in production
      prevent_destroy = false
    }
}

resource "aws_subnet" "public"{
    for_each = local.public_subnet_cidrs

    vpc_id = aws_vpc.main.id
    cidr_block = each.value
    availability_zone = each.key

    # assign_ipv6_address_on_creation = var.enable_ipv6
    # ipv6_cidr_block = var.enable_ipv6 ? local.public_subnet_ipv6_cidrs[count.index] : null
    
    tags = merge(
      var.tags, 
      {
          Name = "${var.vpc_name}-${each.key}-public"
      }
    )
    
    lifecycle {
      # Enable this as true while implementing in production
      prevent_destroy = false
    }
}