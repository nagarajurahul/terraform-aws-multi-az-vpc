provider "aws"{
    region = var.region
}

# Pull available azs dynamically from aws for the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create aws vpc resource
resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr

    tags = merge(
      var.tags, 
      {
        "Name" = var.vpc_name
      }
    )
}


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

}

resource "aws_nat_gateway" "nat"{
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.private[0].id

  tags= merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-nat"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags= merge(
    var.tags, 
    {
      Name = "${var.vpc_name}-private-rt"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}