terraform {
  backend "s3" {
    bucket         = "ci-cd-study.tfstate-bucket-812063706542-ap-northeast-1-an"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "ci_cd_study.tfstate"
    encrypt        = true
  }
}