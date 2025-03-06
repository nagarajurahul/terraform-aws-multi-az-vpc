provider "aws"{
    region = var.region
}

data "aws_regions" "current"{

}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    tags = {
       "Name" = "multi-az-vpc" 
    }
}

resource "aws_subnet" "private"{
    vpc_id = aws_vpc.main.id
    # cidr_block = 
}
