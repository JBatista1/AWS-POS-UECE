
variable "instance_types" {
  default = {
    default = "t2.small"
  }
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
