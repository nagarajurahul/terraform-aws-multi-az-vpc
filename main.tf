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


locals {
    usable_ips = var.number_of_devices_per_subnet + 5 # Add 5 for reserved IPs by AWS

    subnet_mask = (
    local.usable_ips <= 254 ? 24 : # 256 total IPs, 254 usable
    local.usable_ips <= 510 ? 23 : # 512 total IPs, 510 usable
    local.usable_ips <= 1022 ? 22 : 21 # 1024 total IPs, 1022 usable
  )
}

resource "aws_subnet" "private"{
    vpc_id = aws_vpc.main.id
    # cidr_block = 
}