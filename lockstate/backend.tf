terraform {
  backend "s3" {
    bucket         = "kobecyber-terraform-state-bucket"
    key            = "filepath/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kobecyber-terraform-lock-table"
    encrypt        = true
  }
}
