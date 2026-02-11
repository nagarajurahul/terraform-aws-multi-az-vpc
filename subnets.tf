# # Pull available azs dynamically from aws for the current region
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# locals{
#     az_count = length(data.aws_availability_zones.available.names)
# }

locals {
  az_count = length(local.private_azs)

  # Counts number of IPs required per subnet as per devices specified in variables input
  private_subnet_ips = pow(2, 32 - local.private_subnet_mask)

  # Counts number of IPs for all private AZs combined
  required_private_tier_ips = local.az_count * local.private_subnet_ips
}

locals {
  private_tier_mask = (
    local.required_private_tier_ips <= 4096  ? 20 :
    local.required_private_tier_ips <= 8192  ? 19 :
    local.required_private_tier_ips <= 16384 ? 18 : 17
  )
}

locals {
  # Split VPC into large, non-overlapping tiers
  # 16 is VPC cidr range
  public_tier_cidr  = cidrsubnet(var.vpc_cidr, 20-16, 0) # 10.0.0.0/20 -> 4096 IPs for public subnets
  private_tier_cidr = cidrsubnet(var.vpc_cidr, local.private_tier_mask - 16, 1)
}

# Maximum number of devices allocated per subnet will be 4091
# Minimum number of devices allocated will be 251

# Calculate the subnet mask
locals {
    usable_ips = var.number_of_required_ips_per_subnet + 5 # Add 5 for reserved IPs by AWS

    subnet_mask = (
    local.usable_ips <= 256 ? 24 : # 256 total IPs, 251 usable
    local.usable_ips <= 512 ? 23 : # 512 total IPs, 507 usable
    local.usable_ips <= 1024 ? 22 : # 1024 total IPs, 1019 usable
    local.usable_ips <= 2048 ? 21 :20 # 2048 total IPs, 2043 usable
    )
    
    # At most, in highly available production env, we may use 256 IPs per AZ, which is 2pow8
    public_subnet_mask  = 24
    # Dynamic based on input
    private_subnet_mask = local.subnet_mask
}

locals {
  private_azs = [for az,value in var.availability_zones: value.availability_zone if value.private_subnet==true]
  private_azs_with_nat = [for az,value in var.availability_zones: value.availability_zone if value.enable_nat_gateway==true]
  public_azs  = [for az,value in var.availability_zones: value.availability_zone if value.public_subnet==true]
}

# Generate cidrs for public and private subnets
locals{
  public_newbits  = local.public_subnet_mask  - 20
  private_newbits = local.private_subnet_mask - local.private_tier_mask

  private_subnet_cidrs = {
    for i,value in local.private_azs : value => cidrsubnet(local.private_tier_cidr, local.private_newbits, i)
  }

  public_subnet_cidrs = {
    for i,value in local.public_azs :  value => cidrsubnet(local.public_tier_cidr, local.public_newbits, i)
  }  
}

locals {
  public_ipv6_tier  = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 4, 0) # /60
  private_ipv6_tier = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 4, 1) # /60
}

# Generate ipv6 cidrs for public and private subnets
locals {
  private_subnet_ipv6_cidrs = var.enable_ipv6 ? {
    for i,value in local.private_azs : value => cidrsubnet(local.private_ipv6_tier, 4, i)
  } : {}

  public_subnet_ipv6_cidrs = var.enable_ipv6 ? {
    for i,value in local.public_azs  : value => cidrsubnet(local.public_ipv6_tier, 4, i)
  } : {}
}


resource "aws_subnet" "private"{
    for_each = local.private_subnet_cidrs

    vpc_id = aws_vpc.main.id
    cidr_block = each.value
    availability_zone = each.key

    assign_ipv6_address_on_creation = var.enable_ipv6
    ipv6_cidr_block = var.enable_ipv6 ? local.private_subnet_ipv6_cidrs[each.key] : null

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

    assign_ipv6_address_on_creation = var.enable_ipv6
    ipv6_cidr_block = var.enable_ipv6 ? local.public_subnet_ipv6_cidrs[each.key] : null
    
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