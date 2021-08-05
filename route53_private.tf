#creating public hosted zones
resource "aws_route53_zone" "zones" {
  count = (lookup(var.domain_info, "domain_registrar") == "others" || ((lookup(var.domain_info, "domain_registrar") == "aws" && lookup(var.domain_info, "registered") == "no"))) ? 1 : 0
  name = lookup(var.domain_info, "domain_name")
  comment = lookup(var.domain_info, "comments", null)
  tags = merge(
    local.tags,
    {
      "Name" = "${var.domain_info.domain_name}"
      "Cluster_type" = "application"
    },)
}
#adding route53 entry in the hosted zone when domain is already registered in aws route53 uses ALB
resource "aws_route53_record" "app_alb_r53_record_aws_registered" {
  count = (lookup(var.domain_info, "domain_registrar") == "aws" && lookup(var.domain_info, "registered") == "yes") ? 1 : 0
  zone_id = data.aws_route53_zone.data_zones[0].id
  name = "${var.domain_info.sub_domain_name}.${data.aws_route53_zone.data_zones[0].name}"
  type = "A"
  alias {
    name = module.app_eks_alb.lb_dns_name
    zone_id = module.app_eks_alb.lb_zone_id
    evaluate_target_health = true
  }
}

