terraform {
  backend "s3" {
    bucket         = "gerardo-devops-wp"
    key            = "wordpress/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
