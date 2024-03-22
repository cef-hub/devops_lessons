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

