# M2.9 Security - ipset and AWS WAF creation

# What is ipset?
In Amazon Web Services (AWS), an IP set is a collection of IP addresses and ranges that can be used in a rule statement. IP sets are used in AWS WAF to allow, block, or monitor web requests. 
    Use cases 
    Allowing CloudFront requests: Use an IP set to allow requests from CloudFront
    Route53 health checker: Use an IP set to allow requests from the Route53 health checker
    EC2 IP range: Use an IP set to allow requests from the EC2 IP range, which includes AWS Lambda and CloudWatch Synthetics
    
    How to use an IP set 
    Create an AWS resource, IPSet, with your address specifications
    Use the IP set in a web ACL or rule group
    
    Best practices 
    Test the WAF implementation before deploying it to production
    Deploy AWS WAF using Count Mode
    Conduct post deployment evaluations
    
    What is AWS WAF?
    AWS WAF is a web application firewall that protects web applications from attacks. It analyzes HTTP traffic and filters malicious requests. It also defends against common web exploits such as SQL injection and cross-site scripting (XSS). 

# How can I use same lb in 2 different WAF ACL associated resource?
No, you cannot associate the same Application Load Balancer (ALB) with two different AWS WAF Web ACLs; an ALB can only be associated with one WAF Web ACL at a time. 
    Key points to remember:
    One-to-one association: Each ALB can only be linked to a single WAF Web ACL.
    Separate WAF configuration needed: If you want to apply different security rules to the same ALB, you'll need to create separate WAF Web ACLs and associate them with different ALBs or use different listener configurations on the same ALB to route traffic to distinct WAF configurations. 

# What is WAF ACL?
In AWS, a WAF ACL (Web Access Control List) is used to filter incoming web traffic to your application by defining rules that allow, block, or monitor specific HTTP requests based on various criteria like IP addresses, headers, and query strings, essentially acting as a web application firewall to protect against malicious attacks like SQL injection or cross-site scripting (XSS). 
    Key points about AWS WAF ACLs:
    Function:
    It inspects all HTTP/HTTPS requests directed to services like Application Load Balancers, Amazon API Gateway, or AWS AppSync, evaluating them against the defined rules in the ACL to decide whether to allow or block the request. 
    
    Rule creation:
    You can create custom rules within the ACL to specify conditions like specific IP addresses, HTTP headers, URL paths, or even utilize pre-configured managed rules for common attack patterns. 
    
    Action options:
    For each rule, you can choose an action like "Allow," "Block," or "Count" (to monitor traffic without blocking). 
    
    Granular control:
    AWS WAF ACLs allow for fine-grained control over incoming web traffic, enabling you to block specific malicious requests while still allowing legitimate traffic to reach your application. 
    
    Common use cases for AWS WAF ACLs:
    Blocking malicious IP addresses: Prevent access from known malicious IP ranges. 
    Preventing SQL injection attacks: Filter requests containing suspicious patterns in query strings that could be used for SQL injection. 
    Mitigating XSS attacks: Detect and block requests with malicious JavaScript code in input fields. 
    Geo-restriction: Limit access to your website based on user's geographic location. 
    Bot management: Identify and block automated bot traffic that could be harmful to your application. 
    