terraform {
  backend "s3" {
    bucket         = "bucketstatelocksote"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "Jenkins_terraform-lock"
  }
}