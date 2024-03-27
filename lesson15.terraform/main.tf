provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "skruhlik.lesson15"
    key    = "terraform.dev.tfstate"
    region = "us-east-1"
	dynamodb_table = "skruhlik.terraform.lesson15-lock"
  }
}

resource "random_string" "rand_pass" {
  length           = 12
  special          = true
  override_special = "$@"
}

module "ssm_store" {
  source  = "cloudposse/ssm-parameter-store/aws"

  parameter_write = [
    {
      name        = "skruhlik.pass"
      value       = random_string.rand_pass.result
      type        = "SecureString"
      overwrite   = "true"
      description = var.description
    }
  ]

  tags = {
    ManagedBy = "Terraform"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "skruhlik-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1c", "us-east-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "ssm_store_name" {
  value = module.ssm_store.names
}

output "ssm_store_value" {
  value = module.ssm_store.values
  sensitive = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_vgw_id" {
  value = module.vpc.vgw_id
}

output "vpc_nat_ids" {
  value = module.vpc.nat_ids
}




