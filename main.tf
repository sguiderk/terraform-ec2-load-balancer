provider "aws" {
  region                        = var.region
  access_key                    = var.access_key
  secret_key                    = var.secret_key
}

module "group-ec2" {
  ami                            = var.ami
  domain                         = var.domain
  instance_type                  = var.instance_type
  aws_subnet_1                   = module.group-network.aws_subnet_1
  aws_subnet_2                   = module.group-network.aws_subnet_2
  aws_internet_gateway           = module.group-network.aws_internet_gateway
  aws_security_group_sg          = module.group-security.aws_security_group_sg
  source                         = "./modules/ec2-instances"
}

module "group-network" {
  availability_zone              = var.availability_zone
  region                         = var.region
  domain                         = var.domain
  path_certificate_arn           = var.path_certificate_arn
  path_target_group_arn          = var.path_target_group_arn
  aws_instance_server_1          = module.group-ec2.aws_instance_server_1
  aws_instance_server_2          = module.group-ec2.aws_instance_server_2
  aws_security_group_sg          = module.group-security.aws_security_group_sg
  aws_security_group_alb         = module.group-security.aws_security_group_alb
  source                         = "./modules/network-resources"
}

module "group-security" {
  aws_vpc_variables              = module.group-network.aws_vpc
  source                         = "./modules/security-group"
}

