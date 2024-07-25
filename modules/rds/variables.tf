variable "region" {
  description = "AWS region"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
}

variable "storage_type" {
  description = "The storage type"
  type        = string
  default     = "gp2"
}

variable "instance_class" {
  description = "The instance class"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "username" {
  description = "The username for the database"
  type        = string
}

variable "password" {
  description = "The password for the database"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
variable "vpc_security_group_ids" {
  description = "A map of tags to assign to the resource"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "A map of tags to assign to the resource"
  type        = string
}


