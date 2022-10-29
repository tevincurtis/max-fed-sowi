aws_region = "us-west-2"
aws_profile = "default"
terraform_state_dynamodb_table_name = "maxf-004-w2-sowi-prod-terraform_statelock-usw-compute-gms"
terraform_state_bucket_name = "maxf-sowi-us-west-2-compute-gms"
vpc_cidr_block_1 = "10.126.2.0/23"
vpc_cidr_block_2 = "10.126.3.0/25"
vpc_cidr_block_3 = "10.124.9.0/26"
tools_vpc        = "10.116.88.0/22"
availability_zone_1 = "us-west-2a" 
availability_zone_2 = "us-west-2b"
availability_zone_3 = "us-west-2c"
subnets = ["subnet-0e998d36b4ac616b0"]
usw2_sg_ec2 = "sg-06d6d314a36abca08"
usw2_sg_rds = "sg-06d79ea800081820f"
instance_type_node = "c5n.xlarge"
default_route_table_usw2 = "rtb-03c2d88927d91719f"
transit_gateway_id = "tgw-0c676dd37c92d3fb9"
transit_gateway_route_table_id = "tgw-rtb-0721bd0e06db5d2e8"
iam_instance_profile           = "mgep_sowi_profile"
comment = "Route53 for MGEP Application"
ttl = "10"
primaryhealthcheck = "route53-primary-health-check"
secondaryhealthcheck = "route53-secondary-health-check"
identifier1 = "primary"
identifier2 = "secondary"
primaryip = ""
secondaryip = ""
resource_tags = {
    Name                    = "maxf-004-w2-sowi-prod"
    project                 = "SOWI"
    DataClassification      = "restricted"
    Provisioner             = "terraform" 
    environment             = "SOWI"
    owner                   = "owner"
    TechincalPointOfContact = "tevincurtis@maximus.com"
}
