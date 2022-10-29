
locals {
  # Add data from csv file.

  csv_data_us_west_linux = <<-CSV
        instance_name,instance_size,ami_id,az_id,ebs_storage,placement_group,iam_instance_profile,primary_storage,secondary_storage
        004W2AZ1LM025,c5n.xlarge,ami-0ec77350b43a65655,us-west-2a,50,004-PG-GMS,mgep_sowi_profile,50,150
        004W2AZ2LM026,c5n.xlarge,ami-0ec77350b43a65655,us-west-2a,50,004-PG-GMS,mgep_sowi_profile,50,150
        004W2AZ1LM033,c5n.xlarge,ami-0ec77350b43a65655,us-west-2b,50,004-PG-GMS,mgep_sowi_profile,50,150


  CSV

  csv_data_us_west_windows = <<-CSV
        instance_name,instance_size,ami_id,az_id,ebs_storage,placement_group,iam_instance_profile,primary_storage,secondary_storage

  CSV


  us_west_user_data_linux   = file("userdata/userdata.sh")
  us_west_user_data_windows = file("userdata/userdata.ps1")

  us_west_instances_linux         = csvdecode(local.csv_data_us_west_linux)
  us_west_instances_windows       = csvdecode(local.csv_data_us_west_windows)
  us_west_2a_subnet_id            = "subnet-0e998d36b4ac616b0"
  us_west_2b_subnet_id            = "subnet-0e998d36b4ac616b0"
  us_west_linux_security_groups   = ["sg-06d6d314a36abca08"]
  us_west_windows_security_groups = ["sg-06d6d314a36abca08"]
  us_west_key_name                = "sowi-w-prod"
  us_west_tags = {
       Project = "MGEP-004-sowi"
       ChargeCode = "200033.02.00.01"
       BusinessOwner = "MichaelTMateer@maximus.com"
       TechnicalPointOfContact = "TimothyGHoaglund@maximus.com"
       Environment = "PROD"
       Application = "VMHost"
       DataClassification = "Confidential"
       LocationCode = "OR"
       OperatingSystem = "Rhel8"
       BuildTechnician = "2_272891"
       MonitorGroup = "MGEPMON"
       Description = "sowi-PROD-OR-200033.02.00.01"
       backupplan = "sowi-daily"
       "mms:infrastructure:support:name" = "FederalMGEP"
       "mms:infrastructure:support:email" = "TimothyGHoaglund@maximus.com"
  }

  us_west_windows_tags = {
       Project = "MGEP-004-sowi"
       ChargeCode = "200033.02.00.01"
       BusinessOwner = "MichaelTMateer@maximus.com"
       TechnicalPointOfContact = "TimothyGHoaglund@maximus.com"
       Environment = "PROD"
       Application = "VMHost"
       DataClassification = "Confidential"
       LocationCode = "OR"
       OperatingSystem = "Windows2004"
       BuildTechnician = "2_272891"
       MonitorGroup = "MGEPMON"
       Description = "sowi-PROD-OR-200033.02.00.01"
       backupplan = "sowi-daily"
       "mms:infrastructure:support:name" = "FederalMGEP"
       "mms:infrastructure:support:email" = "TimothyGHoaglund@maximus.com"
  }

  west_placement_groups = ["004-PG-GMS"]
}