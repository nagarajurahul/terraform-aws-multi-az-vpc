resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-igw" 
    }
  )
}

resource "aws_route_table" "public"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # IPv6 Route for Public Subnet
  dynamic "route" {
    for_each = var.enable_ipv6 ? [1] : []
    content {
      ipv6_cidr_block = "::/0"
      gateway_id      = aws_internet_gateway.igw.id
    }
  }

  tags = merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  for_each = toset(local.public_azs)

  subnet_id = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}


# Create EIPs for NATs
resource "aws_eip" "nat"{
    for_each = toset(local.private_azs_with_nat)
}

# Create NATs in public subnets in a AZ, where private subnets in that specific AZ need NAT for internet access
# And make sure we have created public subnet for the same AZ
resource "aws_nat_gateway" "nat"{
  for_each = toset(local.private_azs_with_nat)

  allocation_id = aws_eip.nat[each.value].id
  subnet_id = aws_subnet.public[each.value].id

  tags= merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-${each.value}-nat"
    }
  )
}

# resource "aws_egress_only_internet_gateway" "egw" {
#   count = var.enable_ipv6 ? 1 : 0
  
#   vpc_id = aws_vpc.main.id

#   tags = merge(
#     var.tags, 
#     {
#       Name = "${var.vpc_name}-egw"
#     }
#   )
# }



resource "aws_route_table" "private_nat" {
  for_each = toset(local.private_azs_with_nat)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.value].id
  }

  # # IPv6 Route for Private Subnet (If NAT Gateway is enabled)
  # dynamic "route" {
  #   for_each = var.enable_ipv6 ? [1] : []
  #   content {
  #     ipv6_cidr_block = "::/0"
  #     egress_only_gateway_id = aws_egress_only_internet_gateway.egw[0].id
  #   }
  # }

  tags= merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-${each.value}-private-rt"
    }
  )
}

resource "aws_route_table_association" "private_nat" {
  for_each = toset(local.private_azs_with_nat)

  subnet_id = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private_nat[each.value].id
}