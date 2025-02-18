
resource "aws_wafv2_ip_set" "laptop_ip_set" {
  name               = "aalimsee-tf-laptop-ip-set"
  scope              = "REGIONAL" # Change to CLOUDFRONT if needed
  description        = "M2.9 Security by Terraform"
  ip_address_version = "IPV4"
  addresses          = ["42.60.174.38/32"] # <<< curl ifconfig.me to get the public ip address of laptop

  tags = {
    Name = "aalimsee-tf-allow-LaptopIPSet"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl" "example_acl" {
  name        = "aalimsee-tf-waf-acl"
  scope       = "REGIONAL" # Change to CLOUDFRONT if needed
  description = "WAF-ACL-to-allow-only-my-laptopIP"

  default_action {
    block {}
    # allow {}
  }

  rule {
    name     = "AllowLaptopIP"
    priority = 10
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.laptop_ip_set.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AllowLaptopIP"
      sampled_requests_enabled   = true
    }
  }

    rule {
    name     = "BlockAdminPath"
    priority = 8
    action {
      block {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "CONTAINS"
        search_string         = "/admin"

        text_transformation {
          priority = 1
          type     = "LOWERCASE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "BlockAdminPath"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "aalimsee-tf-waf-acl"
    sampled_requests_enabled   = true
  }
}


/* resource "aws_wafv2_web_acl_logging_configuration" "example_logging" {
  log_destination_configs = ["arn:aws:logs:us-east-1:255945442255:log-group:luqman-waf"] # <<< YOUR_ACCOUNT_ID
 // log_destination_configs = ["arn:aws:logs:us-east-1:255945442255:log-group:YOUR_LOG_GROUP"] # <<< YOUR_ACCOUNT_ID
  resource_arn           = aws_wafv2_web_acl.example_acl.arn
} */


/* Can i associate same lb to two waf acl resource? 
No, you cannot associate the same Application Load Balancer (ALB) with two different AWS WAF Web ACLs; an ALB can only be associated with one WAF Web ACL at a time. 
Key points to remember:
One-to-one association: Each ALB can only be linked to a single WAF Web ACL.
Separate WAF configuration needed: If you want to apply different security rules to the same ALB, you'll need to create separate WAF Web ACLs and associate them with different ALBs or use different listener configurations on the same ALB to route traffic to distinct WAF configurations. 
*/
resource "aws_wafv2_web_acl_association" "waf_alb_association" {
  resource_arn = data.aws_lb.my_lb.arn # <<< aws_lb.example_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.example_acl.arn
  lifecycle {
    create_before_destroy = true
  }
}
# Fetch lb arn
data "aws_lb" "my_lb" {
  name = "aalimsee-tf-webapp-alb"
}
output "lb_arn" {
  value = "http://${data.aws_lb.my_lb.arn}"
}