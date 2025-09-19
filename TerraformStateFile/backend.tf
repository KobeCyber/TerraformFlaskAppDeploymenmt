terraform {
  backend "s3" {
    bucket         = "project-terraform-state-bucket"
    key            = "filepath/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-terraform-lock-table"
    encrypt        = true
  }
}
