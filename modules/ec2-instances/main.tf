
variable "aws_subnet_1" {
  description = "Aws subnet 1 from network resource"
}

variable "aws_subnet_2" {
  description = "Aws subnet 2 from network resource"
}

variable "aws_security_group_sg" {
  description = "Aws security group from sg"
}

variable "aws_internet_gateway" {
  description = "Aws internet gateway"
}

################################################################################
# Public subnet EC2 instance 1
################################################################################

resource "aws_instance" "web-server-1-nginx" {
  ami                      = var.ami
  instance_type            = var.instance_type
  security_groups          = [var.aws_security_group_sg.id]
  subnet_id                = var.aws_subnet_1.id
  key_name                 = "servers-key"

  tags = {
    Name                   = "web-server-1"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

################################################################################
# Public subnet EC2 instance 2
################################################################################

resource "aws_instance" "web-server-2-nginx"  {
  ami                       = var.ami
  instance_type             = var.instance_type
  security_groups           = [var.aws_security_group_sg.id]
  subnet_id                 = var.aws_subnet_2.id
  key_name                  = "servers-key"

  tags = {
    Name                    = "web-server-2"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

################################################################################
# Elastic IP resource
################################################################################

resource "aws_eip" "servers-web-server-1-eip" {
  vpc = true

  instance                  = aws_instance.web-server-1-nginx.id
  depends_on                = [var.aws_internet_gateway]
}

resource "aws_eip" "servers-web-server-2-eip" {
  vpc = true

  instance                  = aws_instance.web-server-2-nginx.id
  depends_on                = [var.aws_internet_gateway]
}