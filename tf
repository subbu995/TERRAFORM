     EBS AND IAM USER CODE:
====================================
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
aws configure
  Access key: ..........
  Secret access key: ...........
  region: "us-east-1"  
  output format:table

       vim main.tf
            
provider "aws" {
region = "eu-west-3"
}
locals {
env = "prod"
}
resource "aws_vpc" "one" {
cidr_block = "10.0.0.0/16"
tags = {
Name = "${local.env}-vpc"
}
}
resource "aws_subnet" "two" {
vpc_id = aws_vpc.one.id
cidr_block = "10.0.0.0/24"
tags = {
Name = "${local.env}-subent"
}
}
resource "aws_instance" "three" {
subnet_id = aws_subnet.two.id
ami = "ami-07e67bd6b5d9fd892"
instance_type = "t2.micro"
tags = {
Name = "${local.env}-instance"
}
}
resource "aws_ebs_volume" "four" {
size = 24
availability_zone = "eu-west-3a"
tags = {
Name = "raham-ebs"
}
}
resource "aws_iam_user" "five" {
name = "siva887799"
}
   
  terraform init
  terraform plan
  terraform apply --auto-approve
  terraform destroy --auto-approve

Alias & Providers:
=============================================
it is used to create multiple resource on multiple regions at a time.
            vim main.tf

provider "aws" {
region = "eu-west-3"
}
resource "aws_instance" "one" {
ami = "ami-0b915513496b814ce"
instance_type = "t2.micro"
tags = {
Name = "siva-terra-server"
}
}
provider "aws" {
region = "eu-west-2"
alias = "london"
}
resource "aws_instance" "two" {
provider = aws.london
ami = "ami-0b594cc165f9cddaa"
instance_type = "t2.micro"
tags = {
Name = "siva-terra-server"
}
}

     terraform apply --auto-approve
     terraform destroy --auto-approve


TERRAFORM LIFECYCLE (META ARGUMENTS)
====================================
1.prevent_destroy: it will not destory our resource

      vim main.tf
provider "aws" {
region = "ap-northeast-1"
}
resource "aws_instance" "two" {
ami = "ami-04beabd6a4fb6ab6f"
instance_type = "t2.micro"
tags = {
Name = "tokyo-instance"
}
lifecycle {
prevent_destroy = true
}
}
        terraform apply  --auto-approve
          not possible to destroying resource
   
-->if you destroy the resource

       vim main.tf
provider "aws" {
region = "ap-northeast-1"
}
resource "aws_instance" "two" {
ami = "ami-04beabd6a4fb6ab6f"
instance_type = "t2.micro"
tags = {
Name = "tokyo-instance"
}
lifecycle {
prevent_destroy = false
}
}

        terraform destroy --auto-approve

2.ignore_changes:
===============
-->it will ignore the changes done to infrastructure 
     vim main.tf

provider "aws" {
region = "ap-northeast-1"
}
resource "aws_instance" "two" {
ami = "ami-04beabd6a4fb6ab6f"
instance_type = "t2.micro"
tags = {
Name = "tokyo-instance"
}
lifecycle {
ignore_changes = [
tags["tokyo-instance"]
]
}
}

        terraform apply  --auto-approve
Go to running instance--->tags-->manage tags--->value-opetinal:paris-instance--->save.
        terraform refresh
        cat terraform.tfstate | grep -i tags
        cat terraform.tfstate | grep -i name
Go to running instance--->tags-->manage tags--->Add new tag--->Enter key:security -->Enter value:mumbai-instance-->save.
       terraform refresh
      cat terraform.tfstate | grep -i name
       cat terraform.tfstate | grep -i security

CREATING Security Groups:
========================
          vim main.tf



provider "aws" {
region = "ap-northeast-1"
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}

   terraform apply --auto-approve
   terraform destroy --auto-approve



