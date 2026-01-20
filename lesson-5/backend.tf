terraform {
  backend "s3" {
    bucket         = "graf-lesson-5-terraform"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}