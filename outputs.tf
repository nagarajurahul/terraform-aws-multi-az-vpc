output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDRs for the private subnets"
  value       = local.private_subnet_cidrs
}

output "public_subnet_cidrs" {
  description = "CIDRs for the public subnets"
  value       = local.public_subnet_cidrs
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.id
  }
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}

output "private_subnets" {
  description = "Private subnets"
  value = {
    for az, subnet in aws_subnet.private :
    az => {
      "id"              = subnet.id
      "ipv4_cidr_block" = subnet.cidr_block
      "ipv6_cidr_block" = subnet.ipv6_cidr_block
    }
  }
}

output "public_subnets" {
  description = "Public subnets"
  value = {
    for az, subnet in aws_subnet.public :
    az => {
      "id"              = subnet.id
      "ipv4_cidr_block" = subnet.cidr_block
      "ipv6_cidr_block" = subnet.ipv6_cidr_block
    }
  }
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the VPC"
  value       = var.enable_ipv6 ? aws_vpc.main.ipv6_cidr_block : null
}

output "private_tier_cidr" {
  description = "Public Tier CIDR"
  value       = local.private_tier_cidr
}

output "public_tier_cidr" {
  description = "Public Tier CIDR"
  value       = local.public_tier_cidr
}

output "private_subnet_ipv6_cidrs" {
  description = "IPv6 CIDRs for private subnets"
  value       = var.enable_ipv6 ? local.private_subnet_ipv6_cidrs : null
}

output "public_subnet_ipv6_cidrs" {
  description = "IPv6 CIDRs for public subnets"
  value       = var.enable_ipv6 ? local.public_subnet_ipv6_cidrs : null
}
