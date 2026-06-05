terraform {
  required_version = "1.14.8"
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

  db_password    = var.db_password
  db_username    = var.db_username
  alert_email    = var.alert_email
  key_name       = var.key_name
  my_ip          = var.my_ip
  subnet_cidr_1c = var.subnet_cidr_1c
  env            = var.env  
}