
variable "region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "lb_name" {
  description = "The name of the load balancer."
  type        = string
}

variable "security_groups" {
  description = "The security groups to attach to the load balancer."
  type        = list(string)
}

variable "subnets" {
  description = "The subnets to attach to the load balancer."
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the load balancer."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "target_group_name" {
  description = "The name of the target group."
  type        = string
}

variable "target_group_port" {
  description = "The port for the target group."
  type        = number
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "listener_port" {
  description = "The port for the listener."
  type        = number
}

variable "instance_id" {
  description = "The ID of the EC2 instance to register with the target group."
  type        = string
}
