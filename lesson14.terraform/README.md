#create variables.tf file in root project directory

variable "necessity_db" {
  description = "do we need a database"
  type        = string
  default     = "no"  
}

variable "instance_class" {
  description = "db class instance"
  type        = string
}

variable "cidr_block" {
  description = "cidr_block IP range"
  type        = string
}

#create dev.tfvars file for dev invironment

environment = "skruhlik.dev"
cidr_block = "10.0.100.0/24"
necessity_db = "no"
instance_class = "db.t3.micro"

#create prod.tfvars file for dev invironment

environment = "skruhlik.prod"
cidr_block = "10.0.10.0/24"
necessity_db = "yes"
instance_class = "db.t3.small"

#create terraform workspace

terraform workspace new skruhlik.dev
terraform workspace new skruhlik.prod

D:\terraform\lesson14>terraform workspace list
  default
* skruhlik.dev
  skruhlik.prod
  
#create main.tf terraform project file

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

#run terraform apply for dev without db instance for default

D:\terraform\lesson14>terraform apply -var-file dev.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ssm_parameter.rds_pg_ssm_pass will be created
  + resource "aws_ssm_parameter" "rds_pg_ssm_pass" {
      + arn            = (known after apply)
      + data_type      = (known after apply)
      + id             = (known after apply)
      + insecure_value = (known after apply)
      + key_id         = (known after apply)
      + name           = "pg_ssm_pass"
      + tags_all       = (known after apply)
      + tier           = (known after apply)
      + type           = "SecureString"
      + value          = (sensitive value)
      + version        = (known after apply)
    }

  # aws_vpc.skruhlik-terraform-vpc will be created
  + resource "aws_vpc" "skruhlik-terraform-vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.10.0/24"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Environment" = "skruhlik.development"
          + "Name"        = "skruhlik.vpc-skruhlik.development"
        }
      + tags_all                             = {
          + "Environment" = "skruhlik.development"
          + "Name"        = "skruhlik.vpc-skruhlik.development"
        }
    }

  # random_string.rds_pg_pass will be created
  + resource "random_string" "rds_pg_pass" {
      + id               = (known after apply)
      + length           = 12
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 0
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "\\/@#£$"
      + result           = (known after apply)
      + special          = true
      + upper            = true
    }

Plan: 3 to add, 0 to change, 0 to destroy.
╷
│ Warning: Value for undeclared variable
│
│ The root module does not declare a variable named "environment" but a value was found in file "dev.tfvars". If you meant to use this value, add a "variable"
│ block to the configuration.
│
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all configurations in your organization. To reduce
│ the verbosity of these warnings, use the -compact-warnings option.
╵
╷
│ Warning: Value for undeclared variable
│
│ The root module does not declare a variable named "cidr_block" but a value was found in file "dev.tfvars". If you meant to use this value, add a "variable"
│ block to the configuration.
│
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all configurations in your organization. To reduce
│ the verbosity of these warnings, use the -compact-warnings option.
╵

Do you want to perform these actions in workspace "skruhlik.dev"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_string.rds_pg_pass: Creating...
random_string.rds_pg_pass: Creation complete after 0s [id=1iUPcRQswAM�]
aws_ssm_parameter.rds_pg_ssm_pass: Creating...
aws_vpc.skruhlik-terraform-vpc: Creating...
aws_ssm_parameter.rds_pg_ssm_pass: Creation complete after 1s [id=pg_ssm_pass]
aws_vpc.skruhlik-terraform-vpc: Still creating... [10s elapsed]
aws_vpc.skruhlik-terraform-vpc: Creation complete after 14s [id=vpc-0ad0ef32271e53079]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

D:\terraform\lesson14>terraform destroy -var-file dev.tfvars
var.instance_class
  db class instance

  Enter a value: yes

random_string.rds_pg_pass: Refreshing state... [id=1iUPcRQswAM�]
aws_ssm_parameter.rds_pg_ssm_pass: Refreshing state... [id=pg_ssm_pass]
aws_vpc.skruhlik-terraform-vpc: Refreshing state... [id=vpc-0ad0ef32271e53079]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_ssm_parameter.rds_pg_ssm_pass will be destroyed
  - resource "aws_ssm_parameter" "rds_pg_ssm_pass" {
      - arn       = "arn:aws:ssm:us-east-1:097084951758:parameter/pg_ssm_pass" -> null
      - data_type = "text" -> null
      - id        = "pg_ssm_pass" -> null
      - key_id    = "alias/aws/ssm" -> null
      - name      = "pg_ssm_pass" -> null
      - tags      = {} -> null
      - tags_all  = {} -> null
      - tier      = "Standard" -> null
      - type      = "SecureString" -> null
      - value     = (sensitive value) -> null
      - version   = 1 -> null
    }

  # aws_vpc.skruhlik-terraform-vpc will be destroyed
  - resource "aws_vpc" "skruhlik-terraform-vpc" {
      - arn                                  = "arn:aws:ec2:us-east-1:097084951758:vpc/vpc-0ad0ef32271e53079" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.10.0/24" -> null
      - default_network_acl_id               = "acl-0f62cba62fdfb6237" -> null
      - default_route_table_id               = "rtb-08d5ad411f7d6e94a" -> null
      - default_security_group_id            = "sg-076eb0ea4eb4e471f" -> null
      - dhcp_options_id                      = "dopt-01b63a3034854a4b4" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0ad0ef32271e53079" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-08d5ad411f7d6e94a" -> null
      - owner_id                             = "097084951758" -> null
      - tags                                 = {
          - "Environment" = "skruhlik.development"
          - "Name"        = "skruhlik.vpc-skruhlik.development"
        } -> null
      - tags_all                             = {
          - "Environment" = "skruhlik.development"
          - "Name"        = "skruhlik.vpc-skruhlik.development"
        } -> null
    }

  # random_string.rds_pg_pass will be destroyed
  - resource "random_string" "rds_pg_pass" {
      - id               = "1iUPcRQswAM�" -> null
      - length           = 12 -> null
      - lower            = true -> null
      - min_lower        = 0 -> null
      - min_numeric      = 0 -> null
      - min_special      = 0 -> null
      - min_upper        = 0 -> null
      - number           = true -> null
      - numeric          = true -> null
      - override_special = "\\/@#£$" -> null
      - result           = "1iUPcRQswAM�" -> null
      - special          = true -> null
      - upper            = true -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources in workspace "skruhlik.dev"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_ssm_parameter.rds_pg_ssm_pass: Destroying... [id=pg_ssm_pass]
aws_vpc.skruhlik-terraform-vpc: Destroying... [id=vpc-0ad0ef32271e53079]
aws_ssm_parameter.rds_pg_ssm_pass: Destruction complete after 0s
random_string.rds_pg_pass: Destroying... [id=1iUPcRQswAM�]
random_string.rds_pg_pass: Destruction complete after 0s
aws_vpc.skruhlik-terraform-vpc: Destruction complete after 1s

Destroy complete! Resources: 3 destroyed.

#Switche the workspace

D:\terraform\lesson14>terraform workspace select skruhlik.prod
Switched to workspace "skruhlik.prod".

#terraform apply for prod with db instance for default

D:\terraform\lesson14>terraform apply -var-file prod.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_db_instance.pg_instance[0] will be created
  + resource "aws_db_instance" "pg_instance" {
      + address                               = (known after apply)
      + allocated_storage                     = 10
      + apply_immediately                     = false
      + arn                                   = (known after apply)
      + auto_minor_version_upgrade            = true
      + availability_zone                     = (known after apply)
      + backup_retention_period               = (known after apply)
      + backup_target                         = (known after apply)
      + backup_window                         = (known after apply)
      + ca_cert_identifier                    = (known after apply)
      + character_set_name                    = (known after apply)
      + copy_tags_to_snapshot                 = false
      + db_name                               = "skruhlikprod"
      + db_subnet_group_name                  = (known after apply)
      + delete_automated_backups              = true
      + domain_fqdn                           = (known after apply)
      + endpoint                              = (known after apply)
      + engine                                = "postgres"
      + engine_version                        = "16.2"
      + engine_version_actual                 = (known after apply)
      + hosted_zone_id                        = (known after apply)
      + id                                    = (known after apply)
      + identifier                            = (known after apply)
      + identifier_prefix                     = (known after apply)
      + instance_class                        = "db.t3.small"
      + iops                                  = (known after apply)
      + kms_key_id                            = (known after apply)
      + latest_restorable_time                = (known after apply)
      + license_model                         = (known after apply)
      + listener_endpoint                     = (known after apply)
      + maintenance_window                    = (known after apply)
      + master_user_secret                    = (known after apply)
      + master_user_secret_kms_key_id         = (known after apply)
      + monitoring_interval                   = 0
      + monitoring_role_arn                   = (known after apply)
      + multi_az                              = (known after apply)
      + nchar_character_set_name              = (known after apply)
      + network_type                          = (known after apply)
      + option_group_name                     = (known after apply)
      + parameter_group_name                  = (known after apply)
      + password                              = (sensitive value)
      + performance_insights_enabled          = false
      + performance_insights_kms_key_id       = (known after apply)
      + performance_insights_retention_period = (known after apply)
      + port                                  = (known after apply)
      + publicly_accessible                   = true
      + replica_mode                          = (known after apply)
      + replicas                              = (known after apply)
      + resource_id                           = (known after apply)
      + skip_final_snapshot                   = true
      + snapshot_identifier                   = (known after apply)
      + status                                = (known after apply)
      + storage_throughput                    = (known after apply)
      + storage_type                          = (known after apply)
      + tags_all                              = (known after apply)
      + timezone                              = (known after apply)
      + username                              = "postgres"
      + vpc_security_group_ids                = (known after apply)
    }

  # aws_ssm_parameter.rds_pg_ssm_pass will be created
  + resource "aws_ssm_parameter" "rds_pg_ssm_pass" {
      + arn            = (known after apply)
      + data_type      = (known after apply)
      + id             = (known after apply)
      + insecure_value = (known after apply)
      + key_id         = (known after apply)
      + name           = "pg_ssm_pass"
      + tags_all       = (known after apply)
      + tier           = (known after apply)
      + type           = "SecureString"
      + value          = (sensitive value)
      + version        = (known after apply)
    }

  # aws_vpc.skruhlik-terraform-vpc will be created
  + resource "aws_vpc" "skruhlik-terraform-vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/24"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Environment" = "skruhlik.production"
          + "Name"        = "skruhlik.vpc-skruhlik.production"
        }
      + tags_all                             = {
          + "Environment" = "skruhlik.production"
          + "Name"        = "skruhlik.vpc-skruhlik.production"
        }
    }

  # random_string.rds_pg_pass will be created
  + resource "random_string" "rds_pg_pass" {
      + id               = (known after apply)
      + length           = 12
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 0
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "$@"
      + result           = (known after apply)
      + special          = true
      + upper            = true
    }

Plan: 4 to add, 0 to change, 0 to destroy.
╷
│ Warning: Value for undeclared variable
│
│ The root module does not declare a variable named "cidr_block" but a value was found in file "prod.tfvars". If you meant to use this value, add a "variable"
│ block to the configuration.
│
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all configurations in your organization. To reduce
│ the verbosity of these warnings, use the -compact-warnings option.
╵
╷
│ Warning: Value for undeclared variable
│
│ The root module does not declare a variable named "environment" but a value was found in file "prod.tfvars". If you meant to use this value, add a "variable"
│ block to the configuration.
│
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all configurations in your organization. To reduce
│ the verbosity of these warnings, use the -compact-warnings option.
╵

Do you want to perform these actions in workspace "skruhlik.prod"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_string.rds_pg_pass: Creating...
random_string.rds_pg_pass: Creation complete after 0s [id=fWsUsnAcm79e]
aws_ssm_parameter.rds_pg_ssm_pass: Creating...
aws_vpc.skruhlik-terraform-vpc: Creating...
aws_db_instance.pg_instance[0]: Creating...
aws_ssm_parameter.rds_pg_ssm_pass: Creation complete after 2s [id=pg_ssm_pass]
aws_vpc.skruhlik-terraform-vpc: Still creating... [10s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [10s elapsed]
aws_vpc.skruhlik-terraform-vpc: Creation complete after 15s [id=vpc-08d1ca386d8abf8a3]
aws_db_instance.pg_instance[0]: Still creating... [20s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [30s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [40s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [50s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [1m0s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [1m10s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [1m20s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [1m30s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [1m40s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [1m50s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [2m0s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [2m10s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [2m20s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [2m30s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [2m40s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [2m50s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [3m0s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [3m10s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [3m20s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [3m30s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [3m40s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [3m50s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [4m0s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [4m10s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [4m20s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [4m31s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [4m41s elapsed]
aws_db_instance.pg_instance[0]: Still creating... [4m51s elapsed]
aws_db_instance.pg_instance[0]: Creation complete after 4m52s [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

#destroy terraform configurations

D:\terraform\lesson14>terraform destroy -var-file prod.tfvars
var.instance_class
  db class instance

  Enter a value: yes

random_string.rds_pg_pass: Refreshing state... [id=fWsUsnAcm79e]
aws_ssm_parameter.rds_pg_ssm_pass: Refreshing state... [id=pg_ssm_pass]
aws_vpc.skruhlik-terraform-vpc: Refreshing state... [id=vpc-08d1ca386d8abf8a3]
aws_db_instance.pg_instance[0]: Refreshing state... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_db_instance.pg_instance[0] will be destroyed
  - resource "aws_db_instance" "pg_instance" {
      - address                               = "terraform-20240322111335287100000001.cnq4a58o2rue.us-east-1.rds.amazonaws.com" -> null
      - allocated_storage                     = 10 -> null
      - apply_immediately                     = false -> null
      - arn                                   = "arn:aws:rds:us-east-1:097084951758:db:terraform-20240322111335287100000001" -> null
      - auto_minor_version_upgrade            = true -> null
      - availability_zone                     = "us-east-1d" -> null
      - backup_retention_period               = 0 -> null
      - backup_target                         = "region" -> null
      - backup_window                         = "10:08-10:38" -> null
      - ca_cert_identifier                    = "rds-ca-rsa2048-g1" -> null
      - copy_tags_to_snapshot                 = false -> null
      - customer_owned_ip_enabled             = false -> null
      - db_name                               = "skruhlikprod" -> null
      - db_subnet_group_name                  = "default" -> null
      - delete_automated_backups              = true -> null
      - deletion_protection                   = false -> null
      - domain_dns_ips                        = [] -> null
      - enabled_cloudwatch_logs_exports       = [] -> null
      - endpoint                              = "terraform-20240322111335287100000001.cnq4a58o2rue.us-east-1.rds.amazonaws.com:5432" -> null
      - engine                                = "postgres" -> null
      - engine_version                        = "16.2" -> null
      - engine_version_actual                 = "16.2" -> null
      - hosted_zone_id                        = "Z2R2ITUGPM61AM" -> null
      - iam_database_authentication_enabled   = false -> null
      - id                                    = "db-FCQLJR3NEFEGMUKLYCLTTZE62Y" -> null
      - identifier                            = "terraform-20240322111335287100000001" -> null
      - identifier_prefix                     = "terraform-" -> null
      - instance_class                        = "db.t3.small" -> null
      - iops                                  = 0 -> null
      - license_model                         = "postgresql-license" -> null
      - listener_endpoint                     = [] -> null
      - maintenance_window                    = "wed:05:05-wed:05:35" -> null
      - master_user_secret                    = [] -> null
      - max_allocated_storage                 = 0 -> null
      - monitoring_interval                   = 0 -> null
      - multi_az                              = false -> null
      - network_type                          = "IPV4" -> null
      - option_group_name                     = "default:postgres-16" -> null
      - parameter_group_name                  = "default.postgres16" -> null
      - password                              = (sensitive value) -> null
      - performance_insights_enabled          = false -> null
      - performance_insights_retention_period = 0 -> null
      - port                                  = 5432 -> null
      - publicly_accessible                   = true -> null
      - replicas                              = [] -> null
      - resource_id                           = "db-FCQLJR3NEFEGMUKLYCLTTZE62Y" -> null
      - skip_final_snapshot                   = true -> null
      - status                                = "available" -> null
      - storage_encrypted                     = false -> null
      - storage_throughput                    = 0 -> null
      - storage_type                          = "gp2" -> null
      - tags                                  = {} -> null
      - tags_all                              = {} -> null
      - username                              = "postgres" -> null
      - vpc_security_group_ids                = [
          - "sg-06616d3d5cc61b55c",
        ] -> null
    }

  # aws_ssm_parameter.rds_pg_ssm_pass will be destroyed
  - resource "aws_ssm_parameter" "rds_pg_ssm_pass" {
      - arn       = "arn:aws:ssm:us-east-1:097084951758:parameter/pg_ssm_pass" -> null
      - data_type = "text" -> null
      - id        = "pg_ssm_pass" -> null
      - key_id    = "alias/aws/ssm" -> null
      - name      = "pg_ssm_pass" -> null
      - tags      = {} -> null
      - tags_all  = {} -> null
      - tier      = "Standard" -> null
      - type      = "SecureString" -> null
      - value     = (sensitive value) -> null
      - version   = 1 -> null
    }

  # aws_vpc.skruhlik-terraform-vpc will be destroyed
  - resource "aws_vpc" "skruhlik-terraform-vpc" {
      - arn                                  = "arn:aws:ec2:us-east-1:097084951758:vpc/vpc-08d1ca386d8abf8a3" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/24" -> null
      - default_network_acl_id               = "acl-070305a957ad5dcd8" -> null
      - default_route_table_id               = "rtb-0817c9dc3fc385577" -> null
      - default_security_group_id            = "sg-0f44ab6eb91658ec6" -> null
      - dhcp_options_id                      = "dopt-01b63a3034854a4b4" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-08d1ca386d8abf8a3" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0817c9dc3fc385577" -> null
      - owner_id                             = "097084951758" -> null
      - tags                                 = {
          - "Environment" = "skruhlik.production"
          - "Name"        = "skruhlik.vpc-skruhlik.production"
        } -> null
      - tags_all                             = {
          - "Environment" = "skruhlik.production"
          - "Name"        = "skruhlik.vpc-skruhlik.production"
        } -> null
    }

  # random_string.rds_pg_pass will be destroyed
  - resource "random_string" "rds_pg_pass" {
      - id               = "fWsUsnAcm79e" -> null
      - length           = 12 -> null
      - lower            = true -> null
      - min_lower        = 0 -> null
      - min_numeric      = 0 -> null
      - min_special      = 0 -> null
      - min_upper        = 0 -> null
      - number           = true -> null
      - numeric          = true -> null
      - override_special = "$@" -> null
      - result           = "fWsUsnAcm79e" -> null
      - special          = true -> null
      - upper            = true -> null
    }

Plan: 0 to add, 0 to change, 4 to destroy.

Do you really want to destroy all resources in workspace "skruhlik.prod"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_ssm_parameter.rds_pg_ssm_pass: Destroying... [id=pg_ssm_pass]
aws_vpc.skruhlik-terraform-vpc: Destroying... [id=vpc-08d1ca386d8abf8a3]
aws_db_instance.pg_instance[0]: Destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y]
aws_ssm_parameter.rds_pg_ssm_pass: Destruction complete after 0s
aws_vpc.skruhlik-terraform-vpc: Destruction complete after 1s
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 10s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 20s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 30s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 40s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 50s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 1m0s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 1m10s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 1m20s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 1m30s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 1m40s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 1m50s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 2m0s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 2m10s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 2m20s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 2m30s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 2m40s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 2m50s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 3m0s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 3m10s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 3m20s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 3m30s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 3m40s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 3m50s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 4m0s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 4m10s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 4m20s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 4m30s elapsed]
aws_db_instance.pg_instance[0]: Still destroying... [id=db-FCQLJR3NEFEGMUKLYCLTTZE62Y, 4m40s elapsed]
aws_db_instance.pg_instance[0]: Destruction complete after 4m49s
random_string.rds_pg_pass: Destroying... [id=fWsUsnAcm79e]
random_string.rds_pg_pass: Destruction complete after 0s

Destroy complete! Resources: 4 destroyed.