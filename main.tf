# configure version of aws provider plugin
# https://developer.hashicorp.com/terraform/language/terraform#terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# https://developer.hashicorp.com/terraform/language/values/locals
locals {
  project_name = "lab_week_4"
}

# get the most recent ami for Ubuntu 24.04 owned by amazon
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
# Create a VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "web" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  # enable dns enable_dns_hostnames

  tags = {
    Name         = "project_vpc"
    Project_name = local.project_name
    # add project name using local
  }
}

# Create a public subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# To use the free tier t2.micro ec2 instance you have to declare an AZ
# Some AZs do not support this instance type
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.web.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  # set availability zone 
  # add public ip on launch

  tags = {
    Name         = "Web"
    Project_name = local.project_name
    # add project name using local
  }
}
# Create internet gateway for VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/intern>
resource "aws_internet_gateway" "web-gw" {
  vpc_id = aws_vpc.web.id
  # add vpc

  tags = {
    Name         = "Web"
    Project_name = local.project_name
    # add project name using local
  }
}
# create route table for web VPC 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_>
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.web.id
  # add vpc

  tags = {
    Name         = "web-route"
    Project_name = local.project_name
    # add project name using local
  }
}

# add route to to route table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-gw.id
  # add gateway id
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_>
resource "aws_route_table_association" "web" {
  subnet_id = aws_subnet.web.id
  # add subnet id
  route_table_id = aws_route_table.web.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securi>
resource "aws_security_group" "web" {
  name        = "allow_ssh"
  description = "allow ssh from home and work"
  vpc_id      = aws_vpc.web.id
  # add vpc id

  tags = {
    Name         = "Web"
    Project_name = local.project_name
    # add project name using local
  }
}

# Allow ssh
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_se>
resource "aws_vpc_security_group_ingress_rule" "web-ssh" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  # allow ssh anywhere
}
# allow http
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_se>
resource "aws_vpc_security_group_ingress_rule" "web-http" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  # allow http anywhere
}

# allow all out
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_se>
resource "aws_vpc_security_group_egress_rule" "web-egress" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

# create the ec2 instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instan>
resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  user_data       = file("cloud-config.yaml")
  security_groups = [aws_security_group.web.id]
  # use ami provided by data block above
  # set instance type
  # add user datat for cloud-config file in scripts directory
  # add vpc security group 
  subnet_id = aws_subnet.web.id

  tags = {
    Name         = "Web"
    Project_name = local.project_name
    # add project name using local

  }
}
# print public ip and dns to terminal
# https://developer.hashicorp.com/terraform/language/values/outputs
output "instance_ip_addr" {
  description = "The public IP and dns of the web ec2 instance."
  value = {
    "public_ip" = aws_instance.web.public_ip
    "dns_name"  = aws_instance.web.public_dns
  }
}







