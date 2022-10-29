output "Alb_public_dns_names" {
  value = { for k, v in module.alb : k => v.lb_dns_name }
}
