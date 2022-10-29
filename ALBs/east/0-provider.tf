provider "aws" {
  region     = var.aws_region
  profile    = var.aws_profile
}

# Tfstate S3 Backend
terraform {
  backend "s3" {
    bucket = "maxf-sowi-us-east-1-albs-8443"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_dynamodb_table" "maxf-sowi-e1-nxtgnbpo-prod-terraform_statelock-use-albs-8443" {
  name = var.terraform_state_dynamodb_table_name
  read_capacity = 30
  write_capacity = 30
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = var.terraform_state_bucket_name
    project                 = "maxf-sowi-e1-nxtgnbpo-prod"
    DataClassification      = "restricted"
    Provisioner             = "terraform" 
    environment             = "maxf-sowi-e1-nxtgnbpo-prod"
    owner                   = "owner"
    TechincalPointOfContact = "tevincurtis@maximus.com"
  }
}
