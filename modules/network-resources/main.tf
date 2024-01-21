
################################################################################
# Variables for this module
################################################################################

variable "aws_security_group_alb" {
  description       = "Aws security group alb"
}
variable "aws_security_group_sg" {
  description       = "Aws security group from sg"
}

variable "aws_instance_server_1" {
  description       = "Aws web server 1 nginx"
}

variable "aws_instance_server_2" {
  description       = "Aws web server 2 nginx"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "variables" {
  cidr_block              =  "10.0.0.0/16"
  tags = {
    Name                  = "vpn-tier"
  }
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "variables-tier-1" {
  vpc_id                  = aws_vpc.variables.id
  cidr_block              = "10.0.0.0/18"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Aws subnet 1"
  }
}

resource "aws_subnet" "variables-tier-2" {
  vpc_id                  = aws_vpc.variables.id
  cidr_block              = "10.0.64.0/18"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = "true"
  tags = {
    Name                  = "Aws subnet 2"
  }
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "servers-pvt-sub-1" {
  vpc_id                  = aws_vpc.variables.id
  cidr_block              = "10.0.128.0/18"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name                  = "Private subnet 1"
  }
}
resource "aws_subnet" "servers-pvt-sub-2" {
  vpc_id                  = aws_vpc.variables.id
  cidr_block              = "10.0.192.0/18"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name                  = "Private subnet 2"
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "variables" {
  tags = {
    Name                   = "servers-internet_gateway"
  }
  vpc_id                   = aws_vpc.variables.id
}

################################################################################
# Route Table
################################################################################

resource "aws_route_table" "variables-route" {
  tags = {
    Name                   = "aws_route_table"
  }
  vpc_id                   = aws_vpc.variables.id
  route {
    cidr_block             = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.variables.id
  }
}

################################################################################
# Route Table Association
################################################################################

resource "aws_route_table_association" "variables-route-as-1" {
  subnet_id                = aws_subnet.variables-tier-1.id
  route_table_id           = aws_route_table.variables-route.id
}

resource "aws_route_table_association" "variables-route-as-2" {
  subnet_id                = aws_subnet.variables-tier-2.id
  route_table_id           = aws_route_table.variables-route.id
}

################################################################################
# Load balancer
################################################################################

resource "aws_lb" "servers-lb" {
  name                     = "servers-lb"
  internal                 = false
  load_balancer_type       = "application"
  security_groups          = [var.aws_security_group_alb.id]
  subnets                  = [aws_subnet.variables-tier-1.id, aws_subnet.variables-tier-2.id]

  tags = {
    Environment            = "servers-lb"
  }
}

resource "aws_lb_target_group" "servers-lb-tg" {
  name                     = "servers-lb-tg"
  port                     = 80
  protocol                 = "HTTP"
  vpc_id                   = aws_vpc.variables.id
}

################################################################################
# Load Balancer listener
################################################################################

resource "aws_lb_listener" "servers-lb-listner" {
  load_balancer_arn       = aws_lb.servers-lb.arn
  port                    = "80"
  protocol                = "HTTP"
  default_action {
    type                  = "forward"
    target_group_arn      = aws_lb_target_group.servers-lb-tg.arn
  }
}

################################################################################
# Target group
################################################################################

resource "aws_lb_target_group" "servers-loadb_target" {
  name                    = "target"
  depends_on              = [aws_vpc.variables]
  port                    = "80"
  protocol                = "HTTP"
  vpc_id                  = aws_vpc.variables.id

}

################################################################################
# SSL
################################################################################

resource "aws_lb_target_group_attachment" "servers-tg-attch-1" {
  target_group_arn       = aws_lb_target_group.servers-loadb_target.arn
  target_id              = var.aws_instance_server_1.id
  port                   = 80
}
resource "aws_lb_target_group_attachment" "servers-tg-attch-2" {
  target_group_arn       = aws_lb_target_group.servers-loadb_target.arn
  target_id              = var.aws_instance_server_2.id
  port                   = 80
}

resource "aws_lb" "internal_alb" {
  name                   = "INTERNAL-ALB"
  internal               = true
  load_balancer_type     = "application"
  security_groups        = ["${var.aws_security_group_sg.id}"]
  subnets                = [aws_subnet.variables-tier-1,
                            aws_subnet.variables-tier-2,
                            aws_subnet.servers-pvt-sub-1,
                            aws_subnet.servers-pvt-sub-2]
  enable_deletion_protection = false

  access_logs {
    bucket               = "bucket_name"
    enabled              = true
  }

  tags = {
    Name                 = "INTERNAL-ALB"
  }
}

resource "aws_lb_target_group" "web_alb_target_group" {
    name                    = "Web-Tg"
    port                    = "80"
    protocol                = "HTTP"
    vpc_id                  = "${aws_lb.internal_alb.vpc_id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/heartbeat"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags = {
      Name                  = "Web-Tg"
    }
}

resource "aws_lb_listener" "internal_alb_http" {
  load_balancer_arn         = "${aws_lb.internal_alb.id}"
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = var.path_target_group_arn
  }
}

resource "aws_lb_listener" "internal_alb_https" {
  load_balancer_arn         = "${aws_lb.internal_alb.id}"
  port                      = "443"
  protocol                  = "HTTPS"
  ssl_policy                = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn           = var.path_certificate_arn

  default_action {
    type                    = "forward"
    target_group_arn        =  var.path_target_group_arn
  }
}

################################################################################
# Route53 record
################################################################################

resource "aws_route53_record" "node" {
  zone_id                   = "ZStest"
  name                      =  var.domain
  type                      = "A"
  alias {
    name                    = "${aws_lb.internal_alb.dns_name}"
    zone_id                 = "${aws_lb.internal_alb.zone_id}"
    evaluate_target_health  = true
  }
}