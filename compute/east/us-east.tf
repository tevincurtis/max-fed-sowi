resource "aws_placement_group" "east_default" {
  for_each        = toset(local.east_placement_groups)
  name            = each.value
  strategy        = "spread"
  spread_level    = "rack"
}

module "us_east_ec2_linux" {
  for_each = { for inst in local.us_east_instances_linux : inst.instance_name => inst }
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "~> 3.0"

  name = each.value.instance_name

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_size
  subnet_id                   = each.value.az_id == "us-east-1a" ? local.us_east_1a_subnet_id : local.us_east_1b_subnet_id
  vpc_security_group_ids      = local.us_east_linux_security_groups
  associate_public_ip_address = false
  key_name                    = local.us_east_key_name
  user_data_base64            = base64encode(local.us_east_user_data_linux)
  placement_group             = each.value.placement_group == "default" ? aws_placement_group.east_default["default-pg-east-zone"].id : aws_placement_group.east_default[each.value.placement_group].id
  iam_instance_profile        = each.value.iam_instance_profile
  enable_volume_tags          = false

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = each.value.primary_storage
      tags = {
        Name = each.value.instance_name
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = each.value.secondary_storage
    }
  ]

  tags = merge(local.us_east_tags, { Name = each.value.instance_name, OS = "Linux" }
  )
}


module "us_east_ec2_windows" {
  for_each = { for inst in local.us_east_instances_windows : inst.instance_name => inst }
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "~> 3.0"

  name = each.value.instance_name

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_size
  subnet_id                   = each.value.az_id == "us-east-1a" ? local.us_east_1a_subnet_id : local.us_east_1b_subnet_id
  vpc_security_group_ids      = local.us_east_windows_security_groups
  associate_public_ip_address = false
  key_name                    = local.us_east_key_name
  user_data_base64            = base64encode(local.us_east_user_data_windows)
  placement_group             = each.value.placement_group == "default" ? aws_placement_group.east_default["default-pg-east-zone"].id : aws_placement_group.east_default[each.value.placement_group].id
  iam_instance_profile        = each.value.iam_instance_profile
  enable_volume_tags          = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = each.value.primary_storage
      tags = {
        Name = each.value.instance_name
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = each.value.secondary_storage
    }
  ]

  tags = merge(local.us_east_windows_tags, { Name = each.value.instance_name, OS = "Windowsus" }
  )
}
