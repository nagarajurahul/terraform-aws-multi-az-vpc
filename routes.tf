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
  count = local.az_count

  subnet_id = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat"{
    count = var.enable_nat_gateway ? 1 : 0
}

resource "aws_nat_gateway" "nat"{
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id = aws_subnet.public[0].id

  tags= merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-nat"
    }
  )
}


resource "aws_egress_only_internet_gateway" "egw" {
  count = var.enable_ipv6 ? 1 : 0
  
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-egw"
    }
  )
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }

  # IPv6 Route for Private Subnet (If NAT Gateway is enabled)
  dynamic "route" {
    for_each = var.enable_ipv6 ? [1] : []
    content {
      ipv6_cidr_block = "::/0"
      egress_only_gateway_id = aws_egress_only_internet_gateway.egw[0].id
    }
  }

  tags= merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-private-rt"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = var.enable_nat_gateway ? local.az_count : 0

  subnet_id = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private[0].id
}