terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "allow_ssh" {
  name   = "allow ssh traffic"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_instance" "ubuntu" {    
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.medium"
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    subnet_id = var.subnet_ids[0]
    tags = {
        Name = "AWS UECE Servidor"
    }
    #Criando arquivos com os paths corretos
    user_data     = <<-EOF
                      #!/bin/bash
                      sudo apt-get update -y
                      sudo apt install -y default-jre
                      sudo apt install -y default-jdk
                      sudo apt install -y openjdk-21-jdk
                      sudo apt install -y maven
                      sudo apt install -y nodejs
                      sudo apt install -y npm
                      sudo apt-get install screen
                      cd /home/ubuntu
                      git clone https://github.com/JBatista1/BE-Pos-UECE.git
                      git clone https://github.com/JBatista1/FE-POS-UECE.git
                      sudo chown -R ubuntu:ubuntu /home/ubuntu/BE-Pos-UECE/src/main/resources
                      sudo chown -R ubuntu:ubuntu /home/ubuntu/FE-POS-UECE/src/routes
                      sudo fuser -k /home/ubuntu/BE-Pos-UECE/target || true
                      sudo rm /home/ubuntu/BE-Pos-UECE/src/main/resources/application.properties
                      sudo rm /home/ubuntu/FE-POS-UECE/src/shared/environment/index.ts
                      sudo echo "server.port=8087
                                spring.datasource.url=jdbc:postgresql://${module.rds.rds_endpoint}/postgres
                                spring.datasource.username=postgres
                                spring.datasource.password=postgres
                                spring.jpa.hibernate.ddl-auto=create-drop
                                spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
                                spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation=true
                                spring.jpa.show-sql=true
                                logging.level.com.ead=TRACE
                                logging.level.root=INFO
                                logging.level.org.springframework.web=DEBUG
                                logging.level.org.hibernate=INFO" > BE-Pos-UECE/src/main/resources/application.properties
                      sudo echo "
                      export const Environment = {
                        /**
                        * Define a quantidade de linhas a ser carregada por padrão nas listagens
                        */
                        LIMITE_DE_LINHAS: 5,
                        /**
                        * Placeholder exibido nas inputs
                        */
                        INPUT_DE_BUSCA: 'Pesquisar...',
                        /**
                        * Texto exibido quando nenhum registro é encontrado em uma listagem
                        */
                        LISTAGEM_VAZIA: 'Nenhum registro encontrado.',
                        /**
                        * Url base de consultado dos dados dessa aplicação
                        */
                        URL_BASE: 'http://$(curl -s http://169.254.169.254/latest/meta-data/public-hostname):8087'
                      };" > FE-POS-UECE/src/shared/environment/index.ts
                      cd BE-Pos-UECE
                      sudo mvn clean package
                      sudo chown -R ubuntu:ubuntu /home/ubuntu/BE-Pos-UECE/target
                      sudo chown -R ubuntu:ubuntu /home/ubuntu
                      sudo chown -R ubuntu:ubuntu /home/ubuntu/FE-POS-UECE
                      cd target
                      screen -S contasapagar
                      nohup sudo java -jar contasAPagar-0.0.1-SNAPSHOT.jar > /home/ubuntu/contasAPagar.log 2>&1 &
                      cd ../..
                      cd FE-POS-UECE
                      sudo npm install
                      nohup sudo npm start > /home/ubuntu/myreactapp.log 2>&1 &
                      echo "Hello, World!" > /home/ubuntu/hello.txt
                    EOF
}
module "rds" {
    source                  = "./modules/rds"
    region                  = "us-east-1"
    allocated_storage       = 20
    storage_type            = "gp2"
    instance_class          = "db.t3.micro"
    db_name                 = "mydatabase"
    username                = "postgres"
    password                = "postgres"
    db_subnet_group_name    = aws_db_subnet_group.default.name  # Add the db_subnet_group_name attribute
    vpc_security_group_ids  = [aws_security_group.allow_ssh.id]  # Add the vpc_security_group_ids attribute
    tags                    = {
        Name = "MyRDSInstance"
    }
}

module "loadbalance" {
  source                   = "./modules/loadbalance"
  region                   = "us-east-1"
  lb_name                  = "LoadBalance"
  security_groups          = [aws_security_group.allow_ssh.id]
  subnets                  = var.subnet_ids
  enable_deletion_protection = false
  tags                     = {
    Name = "example-lb"
  }
  target_group_name        = "example-tg"
  target_group_port        = 80
  vpc_id                   = var.vpc_id
  listener_port            = 80
  instance_id              = aws_instance.ubuntu.id
}


output "rds_address" {
  description = "The address of the RDS instance"
  value       = module.rds.rds_endpoint
}

