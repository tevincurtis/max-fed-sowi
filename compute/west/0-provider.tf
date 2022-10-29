provider "aws" {
  region     = var.aws_region
  profile    = var.aws_profile
}

# Tfstate S3 Backend
terraform {
  backend "s3" {
    bucket = "maxf-sowi-us-west-2-compute-gms"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_dynamodb_table" "maxf-sowi-w2-sowi-prod-terraform_statelock-use-compute-gms" {
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
    project                 = "maxf-sowi-w2-sowi-prod"
    DataClassification      = "restricted"
    Provisioner             = "terraform" 
    environment             = "maxf-sowi-w2-sowi-prod"
    owner                   = "owner"
    TechincalPointOfContact = "tevincurtis@maximus.com"
  }
}
