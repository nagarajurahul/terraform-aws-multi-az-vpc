provider "aws"{
    region = var.region
}


data "aws_regions" "current"{

}

# Pull avialable azs dynamically from aws for the current region
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
       "Name" = var.vpc_name
    }
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

    tags={
      Name = "${var.vpc_name}-private-${count.index}"
    }
}

resource "aws_subnet" "public"{
    count = local.az_count

    vpc_id = aws_vpc.main.id
    cidr_block = local.public_subnet_cidrs[count.index]
    availability_zone = element(data.aws_availability_zones.available.names,count.index)

    tags={
        Name = "${var.vpc_name}-public-${count.index}"
    }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat"{

}

resource "aws_nat_gateway" "nat"{
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.private[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}