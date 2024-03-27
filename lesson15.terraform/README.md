## Initializing Terraform

D:\terraform\lesson15_1>terraform init

Initializing the backend...
Initializing modules...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 2.0.0"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/aws v5.42.0...
- Installed hashicorp/aws v5.42.0 (signed by HashiCorp)
- Installing hashicorp/random v3.6.0...
- Installed hashicorp/random v3.6.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

## File main.tf SSM and VPC module

```hcl
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
```

##  Terraform apply

D:\terraform\lesson15_1>terraform apply

Apply complete! Resources: 34 added, 0 changed, 0 destroyed.

##  Outputs

```hcl
ssm_store_name = tolist([
  "skruhlik.pass",
])
ssm_store_value = <sensitive>
vpc_id = "vpc-0090eb4f49299a992"
vpc_nat_ids = [
  "eipalloc-0a3d1e2b64eb23fc8",
  "eipalloc-07b315c69a836a696",
  "eipalloc-097483eaf54a24bfd",
]
vpc_private_subnets = [
  "subnet-00b365986056f3bfd",
  "subnet-0443e4edbfa556be2",
  "subnet-058a936787bf7dfc8",
]
vpc_public_subnets = [
  "subnet-0017c02116054f07e",
  "subnet-0d182f98dd8a5abb5",
  "subnet-015b4e67fb5df8a10",
]
vpc_vgw_id = "vgw-0fc8ef653928b5425"
```

##  Terraform destroy

D:\terraform\lesson15_1>terraform destroy
Destroy complete! Resources: 34 destroyed.