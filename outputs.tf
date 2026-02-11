output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_cidrs"{
    description = "CIDRs for the private subnets"
    value = local.private_subnet_cidrs
}

output "public_subnet_cidrs"{
    description = "CIDRs for the public subnets"
    value = local.public_subnet_cidrs
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = aws_subnet.private.*.id
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the VPC"
  value       = var.enable_ipv6 ? aws_vpc.main.ipv6_cidr_block : null
}

output "private_subnet_ipv6_cidrs" {
  description = "IPv6 CIDRs for private subnets"
  value       = var.enable_ipv6 ? local.private_subnet_ipv6_cidrs : null

  sensitive   = true
}

output "public_subnet_ipv6_cidrs" {
  description = "IPv6 CIDRs for public subnets"
  value       = var.enable_ipv6 ? local.public_subnet_ipv6_cidrs : null

  sensitive   = true
}
