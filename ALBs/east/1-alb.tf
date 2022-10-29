locals {
  alb_tags = {
    "Project" = "MGEP-004-SOWI",
    "Application" = "App",
    "Owner"       = "Infra"
  }
  r53_domain_name = var.domain
}

data "aws_route53_zone" "domain_info" {
  name = local.r53_domain_name
}
resource "aws_route53_record" "alias_route53_record_primary" {
  for_each = { for value in var.albs_with_certs : value.alb_name => value }
  zone_id  = data.aws_route53_zone.domain_info.zone_id
  name     = each.value.r53_record_primary_name
  type     = "A"
  set_identifier = "primary"


  failover_routing_policy {
    type = "PRIMARY"
  }
  alias {
    name                   = module.alb[each.value.alb_name].lb_dns_name
    zone_id                = module.alb[each.value.alb_name].lb_zone_id
    evaluate_target_health = true
  }
}
/*
resource "aws_route53_record" "add_record" {
  for_each = { for value in var.albs_with_certs : value.alb_name => value }
  zone_id  = data.aws_route53_zone.domain_info.zone_id
  name     = each.value.r53_record_name
  type     = "A"
  alias {
    name                   = module.alb[each.value.alb_name].lb_dns_name
    zone_id                = module.alb[each.value.alb_name].lb_zone_id
    evaluate_target_health = true
  }
}
*/
module "alb" {
  for_each = { for value in var.albs_with_certs : value.alb_name => value }

  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = each.value.alb_name

  load_balancer_type = "application"
  internal = true

  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  security_groups = var.security_groups_ids


  target_groups = [
    {
      name      = "${each.value.tg_name}"
      backend_protocol = "${each.value.bkp_protocol}"
      backend_port     = "${each.value.tgbkp_port}"
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "${each.value.tg_healthcheckpath}"
        port                = "${each.value.tg_port}"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200,404"
        stickiness = {
            enabled = each.value.stickiness_state
            type = "lb_cookie"
        }
      }
      targets = {
        my_LM025_target = {
          target_id = "${each.value.instance_LM025_id}"
          port      = 8443
        }
        my_LM026_target = {
          target_id = "${each.value.instance_LM026_id}"
          port      = 8443
        }
        my_LM033_target = {
          target_id = "${each.value.instance_LM033_id}"
          port      = 8443
        }        
      }
    }
  ]

  https_listeners = [

    {
      port               = 8443
      protocol           = "HTTPS"
      certificate_arn    = "${each.value.acm_cert_arn}"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = merge(local.alb_tags, { Name = "App-alb" })
}
