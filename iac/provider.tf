provider "aws" {
  region     = "ca-central-1"
}

# Share Terraform State file
terraform {
  backend "s3" {
    bucket = "terraform-state-backend-igti-challenge"
    key = "terraform-state/shared-terraform-state.tfstate"
    region = "ca-central-1"
  }
}
