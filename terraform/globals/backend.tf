terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"     # Create in AWS S3 first
    key            = "aws-sandbox/dev/us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"               # Optional, for locking
    encrypt        = true
  }
}
