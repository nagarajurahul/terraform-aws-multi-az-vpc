provider "aws"{
    region = var.region
}

data "aws_regions" "current"{

}

resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    tags = {
       "Name" = "multi-az-vpc" 
    }
}

resource "aws_subnet" "public"{
    vpc_id = aws_vpc.main.id
    # cidr_block = 
}
