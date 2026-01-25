terraform {
  backend "s3" {
    bucket         = "graf-lesson-5-tfstate-2026"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}