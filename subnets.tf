locals{
    az_count = length(data.aws_availability_zones.available.names)
}

# Maximum number of devices allocated per subnet will be 2041
# Minimum number of devices allocated will be 249

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
    for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_mask - 16, i + 1)
  ]

  public_subnet_cidrs = [
    for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, local.subnet_mask - 16, i + local.az_count + 1)
  ]  
}



resource "aws_subnet" "private"{
    count = local.az_count

    vpc_id = aws_vpc.main.id
    cidr_block = local.private_subnet_cidrs[count.index]
    availability_zone = element(data.aws_availability_zones.available.names,count.index)

    tags = merge(
      var.tags, 
      {
        Name = "${var.vpc_name}-private-${count.index}"
      }
    )
}

resource "aws_subnet" "public"{
    count = local.az_count

    vpc_id = aws_vpc.main.id
    cidr_block = local.public_subnet_cidrs[count.index]
    availability_zone = element(data.aws_availability_zones.available.names,count.index)

    tags = merge(
      var.tags, 
      {
          Name = "${var.vpc_name}-public-${count.index}"
      }
    )
}