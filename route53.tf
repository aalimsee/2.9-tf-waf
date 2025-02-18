
# Create an ACM certificate for HTTPS
resource "aws_acm_certificate" "my_cert" {
  domain_name       = "aalimsee-tf-waf.sctp-sandbox.com"  # Replace with your domain
  validation_method = "DNS"

  subject_alternative_names = [
    "www.aalimsee-tf-waf.sctp-sandbox.com"
  ]
  lifecycle {
    create_before_destroy = true
  }
}

# Fetch existing Route 53 Hosted Zone
data "aws_route53_zone" "existing_zone" {
  name = "sctp-sandbox.com"  # Replace with your domain
}

# Create Route 53 Record for Certificate Validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.my_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Validate the certificate
resource "aws_acm_certificate_validation" "my_cert_validation" {
  certificate_arn         = aws_acm_certificate.my_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Create an A Record to point to the ALB
resource "aws_route53_record" "alb_dns" {
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = "aalimsee-tf-waf.sctp-sandbox.com"  # Replace with your subdomain
  type    = "A"

  alias {
    name                   = data.aws_lb.my_lb.dns_name
    zone_id                = data.aws_lb.my_lb.zone_id
    evaluate_target_health = true
  }
}




/* 


# Fetch existing Route 53 Hosted Zone
data "aws_route53_zone" "existing_zone" {
  name = "sctp-sandbox.com"  # Replace with your domain
}

# Create an A Record to point to the ALB
resource "aws_route53_record" "alb_dns" {
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = "aalimsee-tf-waf.sctp-sandbox.com"  # Replace with your subdomain
  type    = "A"

  alias {
    name                   = aws_lb.my_lb.dns_name
    zone_id                = aws_lb.my_lb.zone_id
    evaluate_target_health = true
  }
}

# HTTPS Listener for ALB
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "HTTPS OK"
      status_code  = "200"
    }
  }
}
 */