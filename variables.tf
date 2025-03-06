variable "vpc_cidr"{
    type = string
    default = "10.0.0.0/16"
}

variable "region"{
    type = string
    description = "The AWS Region where VPC will be deployed"

    validation {
      condition = contains(data.aws_regions.current.names, lower(var.region))
      error_message = "Please enter a valid AWS region"
    }
}