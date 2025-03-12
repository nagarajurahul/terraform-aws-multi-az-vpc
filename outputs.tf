output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "private_subnet_cidrs"{
    description = "CIDRs for the private subnets"
    value = local.private_subnet_cidrs
}

output "public_subnet_cidrs"{
    description = "CIDRs for the public subnets"
    value = local.public_subnet_cidrs
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = aws_subnet.private.*.id
  sensitive   = true
}