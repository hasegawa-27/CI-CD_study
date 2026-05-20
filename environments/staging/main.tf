terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "main" {
  source = "../../modules"

  key_name       = var.key_name
  my_ip          = var.my_ip
  db_username    = var.db_username
  db_password    = var.db_password
  alert_email    = var.alert_email
  subnet_cidr_1c = var.subnet_cidr_1c
  env            = var.env  
}