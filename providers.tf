provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "azs" {
}

data "aws_ami" "example" {
  owners = ["amazon"]
  most_recent = true
}
