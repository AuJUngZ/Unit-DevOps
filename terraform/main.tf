provider "aws" {
  region = "ap-southeast-1"
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  # azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# # VPC Endpoint for S3 (Gateway Endpoint)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = module.vpc.vpc_id
#   service_name = "com.amazonaws.ap-southeast-1.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = module.vpc.private_route_table_ids

#   tags = {
#     Name = "s3-vpc-endpoint"
#   }
# }

# # VPC Endpoint for EC2 (Interface Endpoint)
# resource "aws_vpc_endpoint" "ec2" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.ap-southeast-1.ec2"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ec2-vpc-endpoint"
#   }
# }

# # Security Group for VPC Endpoints
# resource "aws_security_group" "vpc_endpoint_sg" {
#   name        = "vpc-endpoint-sg"
#   description = "Security group for VPC endpoints"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [module.vpc.vpc_cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "vpc-endpoint-sg"
#   }
# }