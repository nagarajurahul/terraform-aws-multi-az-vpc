provider "aws"{
    region = var.region
}

resource "aws_vpc" "multi_az"{
    cidr_block = var.vpc_cidr
    
}