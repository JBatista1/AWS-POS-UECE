provider "aws" {
  region = var.region
}

resource "aws_db_instance" "postgresql" {
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = "postgres"
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  skip_final_snapshot  = true
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name = var.db_subnet_group_name

  tags = var.tags
}
