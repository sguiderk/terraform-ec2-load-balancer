
output "aws_security_group_sg" {
  value = aws_security_group.server-ec2-sg
}

output "aws_security_group_alb" {
  value = aws_security_group.server-alb-sg
}