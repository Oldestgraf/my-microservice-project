terraform {
  backend "s3" {
    # NOTE: backend does NOT support variables. Edit these values to match your setup.
    bucket         = "YOUR_TFSTATE_BUCKET"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
