# terraform-ec2-load-balancer

### how to run the code 
`terraform init `

`terraform apply`

if you want to pass all your params you can use this command 

`terraform plan -var "access_key=test" -var "secret_key=test" -var "region=eu-west-1" -var "ami=ami-064eb0bee0c5402c5" -var "domain=code.studucu.com" -var "availability_zone=ap-southeast-1b" -var "instance_type=t2.micro"  -var "path_target_group_arn=test" -var "path_certificate_arn=test"
`

This structure separates the infrastructure into a modular setup, making it clear, reusable, and potentially extensible for future changes. Ensure that you replace placeholder values with your actual data.

Remember to handle sensitive information, such as AWS credentials, carefully and consider implementing secure practices for managing secrets in a production environment. Additionally, follow best practices for infrastructure as code and AWS security.