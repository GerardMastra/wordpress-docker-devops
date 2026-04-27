terraform {
  backend "s3" {
    bucket         = "TU_BUCKET_TF_STATE"
    key            = "wordpress/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
