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
  //name = "aalimsee-tf-webapp-alb"
  tags = {Name = "aalimsee-tf-webapp-alb"}
}
output "lb_arn" {
  value = "http://${data.aws_lb.my_lb.arn}"
}

# Add HTTPS Listener to existing ALB <<<
resource "aws_lb_listener" "https" {
  load_balancer_arn = "${data.aws_lb.my_lb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.my_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.web_app.arn # <<<
    
    /* type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "HTTPS OK"
      status_code  = "200" */
    }
    depends_on = [aws_acm_certificate_validation.my_cert_validation] # ensure cert is create before adding the listener
  }

# Fetch target group with name
# or aws elbv2 describe-target-groups --query "TargetGroups[*].{Name:TargetGroupName, ARN:TargetGroupArn}"

data "aws_lb_target_group" "web_app" {
   name = "aalimsee-tf-webapp" # <<< no filter option available
}
output "target_group_arn" {
  value = data.aws_lb_target_group.web_app.arn
}

