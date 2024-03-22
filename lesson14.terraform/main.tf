provider "aws" {
  region = "us-east-1"
}

locals {
environment = terraform.workspace == "skruhlik.dev" ? "skruhlik.development" : "skruhlik.production"
environment_db = terraform.workspace == "skruhlik.dev" ? "skruhlikdev" : "skruhlikprod"
}

resource "aws_vpc" "skruhlik-terraform-vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "skruhlik.vpc-${local.environment}"
    Environment = local.environment  
  }
}

resource "random_string" "rds_pg_pass" {
  length           = 12
  special          = true
  override_special = "$@"
}

resource "aws_ssm_parameter" "rds_pg_ssm_pass" {
  name  = "pg_ssm_pass.${local.environment_db}"
  type  = "SecureString"
  value = random_string.rds_pg_pass.result
}

resource "aws_db_instance" "pg_instance" {
  count = var.necessity_db == "yes" ? 1 : 0
  
  allocated_storage    = 10
  db_name              = "${local.environment_db}"
  engine               = "postgres"
  engine_version       = "16.2"
  instance_class       = var.instance_class
  username             = "postgres"
  password             = random_string.rds_pg_pass.result
  publicly_accessible  = true
  skip_final_snapshot  = true
}