
locals {
  # Add data from csv file.
  csv_data_us_east_linux = <<-CSV
      instance_name,instance_size,ami_id,az_id,ebs_storage,placement_group,iam_instance_profile,primary_storage,secondary_storage
      004E1AZ1LM025,c5n.xlarge,ami-0fd362817ce2ddb71,us-east-1a,200,004-PG-GMS,mgep_sowi_profile,50,150
      004E1AZ2LM026,c5n.xlarge,ami-0fd362817ce2ddb71,us-east-1a,200,004-PG-GMS,mgep_sowi_profile,50,150
      004E1AZ1LM033,c5n.xlarge,ami-0fd362817ce2ddb71,us-east-1b,200,004-PG-GMS,mgep_sowi_profile,50,150

  CSV


  csv_data_us_east_windows = <<-CSV
        instance_name,instance_size,ami_id,az_id,ebs_storage,placement_group,iam_instance_profile,primary_storage,secondary_storage    

  CSV


  us_east_user_data_linux   = file("userdata/userdata.sh")
  us_east_user_data_windows = file("userdata/userdata.ps1")

  us_east_instances_linux         = csvdecode(local.csv_data_us_east_linux)
  us_east_instances_windows       = csvdecode(local.csv_data_us_east_windows)
  us_east_1a_subnet_id            = "subnet-0c452a624fa6fc468"
  us_east_1b_subnet_id            = "subnet-05a98e80b9266939f"
  us_east_linux_security_groups   = ["sg-03383addabcf61c6c"]
  us_east_windows_security_groups = ["sg-03383addabcf61c6c"]
  us_east_key_name                = "sowi-prod"
  us_east_tags = {
       Project = "MGEP-004-SOWI"
       ChargeCode = "200043.02.00.01"
       BusinessOwner = "MichaelTMateer@maximus.com"
       TechnicalPointOfContact = "TimothyGHoaglund@maximus.com"
       Environment = "PROD"
       DataClassification = "Confidential"
       LocationCode = "VA"
       OperatingSystem = "Rhel8"
       BuildTechnician = "2_272891"
       MonitorGroup = "MGEPMON"
       Description = "SOWI-PROD-OR-200043.02.00.01"
       Requestor = "ScottAClarke@maximus.com"
       backupplan = "SOWI-daily"
       "mms:infrastructure:support:name" = "FederalMGEP"
       "mms:infrastructure:support:email" = "TimothyGHoaglund@maximus.com"
  }

  us_east_windows_tags = {
       Project = "MGEP-004-SOWI"
       ChargeCode = "200043.02.00.01"
       BusinessOwner = "MichaelTMateer@maximus.com"
       TechnicalPointOfContact = "TimothyGHoaglund@maximus.com"
       Environment = "PROD"
       DataClassification = "Confidential"
       LocationCode = "VA"
       OperatingSystem = "Windows2004"
       BuildTechnician = "2_272891"
       MonitorGroup = "MGEPMON"
       Description = "SOWI-PROD-OR-200043.02.00.01"
       Requestor = "ScottAClarke@maximus.com"
       backupplan = "SOWI-daily"
       "mms:infrastructure:support:name" = "FederalMGEP"
       "mms:infrastructure:support:email" = "TimothyGHoaglund@maximus.com"
  }
  east_placement_groups = ["004-PG-GMS"]
}
