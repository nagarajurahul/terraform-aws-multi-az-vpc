output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main
}

output "private_subnet_cidrs"{
    description = "CIDRs for the private subnets"
    value = local.private_subnet_cidrs
}

output "public_subnet_cidrs"{
    description = "CIDRs for the public subnets"
    value = local.public_subnet_cidrs
}