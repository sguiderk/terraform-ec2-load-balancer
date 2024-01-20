variable "aws_vpc_variables" {
  description = "Aws vpc variables from network resource"
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "server-ec2-sg" {
  name        = "server-ec2-sg"
  description = "For allowing the traffic in the vpc"
  vpc_id      = var.aws_vpc_variables
  depends_on = [
   var.aws_vpc_variables
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "server-ec2-sg"
  }
}

################################################################################
# Security group for Load balancer
################################################################################

resource "aws_security_group" "server-alb-sg" {
  name        = "server-alb-sg"
  description = "Security group for load balancer"
  vpc_id      =var.aws_vpc_variables.id
  depends_on = [
   var.aws_vpc_variables
  ]

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "server-alb-sg"
  }
}


resource "aws_security_group" "ecs_sg" {
  name        = "server-ecs-sg"
  description = "Security group for ECS"
  vpc_id      =var.aws_vpc_variables.id
  ingress {
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "server-ecs-sg"
    }
}