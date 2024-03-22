provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "skruhlik-terraform-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "skruhlik-terraform-public-subnet" {
  vpc_id         = aws_vpc.skruhlik-terraform-vpc.id
  cidr_block     = "10.0.10.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "skruhlik-terraform-public-subnet"
  }
}

resource "aws_subnet" "skruhlik-terraform-private-subnet" {
  vpc_id                  = aws_vpc.skruhlik-terraform-vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-east-1d"
  tags = {
    Name = "skruhlik-terraform-private-subnet"
  }
}

resource "aws_security_group" "skruhlik-sg-terraform-ssh22" {
  name        = "skruhlik-sg-terraform-ssh22"
  description = "skruhlik-sg-terraform-ssh22"
  vpc_id      = aws_vpc.skruhlik-terraform-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["185.183.33.218/32", "86.57.156.230/32"]  
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_instance" "skruhlik-terraform-ec2" {
  ami                    = "ami-044a3516c1b05985f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.skruhlik-terraform-public-subnet.id
  vpc_security_group_ids = [aws_security_group.skruhlik-sg-terraform-ssh22.id]
  key_name               = "devops"

  tags = {
    Name = "skruhlik-terraform-ec2"
  }
}

output "terraform_instance_id" {
  value = aws_instance.skruhlik-terraform-ec2.id
}

data "aws_security_group" "data_skruhlik-sg-terraform-ssh22" {
  name = aws_security_group.skruhlik-sg-terraform-ssh22.name
}

output "terraform_sg_id" {
  value = data.aws_security_group.data_skruhlik-sg-terraform-ssh22.id
}

output "terraform_sg_vpc_id" {
  value = data.aws_security_group.data_skruhlik-sg-terraform-ssh22.vpc_id
}
