
output "aws_subnet_1" {
  value = aws_subnet.variables-tier-1
}

output "aws_subnet_2" {
  value = aws_subnet.variables-tier-2
}

output "aws_vpc" {
  value = aws_vpc.variables
}


output "aws_internet_gateway" {
  value = aws_internet_gateway.variables
}
