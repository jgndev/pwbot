terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# App Runner service
resource "aws_apprunner_service" "pwbot" {
  service_name = "pwbot-service"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_service_role.arn
    }
    image_repository {
      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          "LOG_LEVEL" = "DEBUG"
        }
      }
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }

  health_check_configuration {
    healthy_threshold   = 1
    interval            = 5
    path                = "/"
    protocol            = "HTTP"
    timeout             = 2
    unhealthy_threshold = 5
  }

  tags = {
    Name = "pwbot-service"
  }

  depends_on = [aws_iam_role_policy_attachment.apprunner_service_role_policy, aws_iam_role_policy_attachment.apprunner_service_role_cloudwatch_policy]
}

# IAM role for App Runner to access ECR
resource "aws_iam_role" "apprunner_service_role" {
  name = "apprunner-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_service_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  role       = aws_iam_role.apprunner_service_role.name
}

resource "aws_iam_role_policy_attachment" "apprunner_service_role_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.apprunner_service_role.name
}

# Custom domain configuration
resource "aws_apprunner_custom_domain_association" "pwbot" {
  domain_name = "pwbot.jgn.dev"
  service_arn = aws_apprunner_service.pwbot.arn
}

# Get the hosted zone for jgn.dev
data "aws_route53_zone" "jgn_dev" {
  name = "jgn.dev."
}

# Create CNAME record for custom domain
resource "aws_route53_record" "pwbot" {
  zone_id = data.aws_route53_zone.jgn_dev.zone_id
  name    = "pwbot.jgn.dev"
  type    = "CNAME"
  ttl     = 300
  records = [aws_apprunner_custom_domain_association.pwbot.dns_target]
}

# Create ACM Certificate for pwbot.jgn.dev
resource "aws_acm_certificate" "pwbot" {
  domain_name       = "pwbot.jgn.dev"
  validation_method = "DNS"

  tags = {
    Name = "pwbot.jgn.dev-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS record for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.pwbot.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.jgn_dev.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "pwbot" {
  certificate_arn         = aws_acm_certificate.pwbot.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# App Runner custom domain association
resource "aws_apprunner_custom_domain_association" "pwbot" {
  domain_name = "pwbot.jgn.dev"
  service_arn = aws_apprunner_service.pwbot.arn
}

# Create CNAME record for custom domain
resource "aws_route53_record" "pwbot" {
  zone_id = data.aws_route53_zone.jgn_dev.zone_id
  name    = "pwbot.jgn.dev"
  type    = "CNAME"
  ttl     = 300
  records = [aws_apprunner_custom_domain_association.pwbot.dns_target]
}

# Outputs
output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "The URL of the ECR repository"
}

output "apprunner_service_url" {
  value       = aws_apprunner_service.pwbot.service_url
  description = "The URL of the App Runner service"
}

output "custom_domain" {
  value       = aws_apprunner_custom_domain_association.pwbot.domain_name
  description = "The custom domain associated with the App Runner service"
}

output "cname_record" {
  value       = aws_route53_record.pwbot.name
  description = "The CNAME record created in Route 53"
}

output "certificate_arn" {
  value       = aws_acm_certificate.pwbot.arn
  description = "The ARN of the ACM certificate for pwbot.jgn.dev"
}

output "certificate_status" {
  value       = aws_acm_certificate.pwbot.status
  description = "The status of the ACM certificate for pwbot.jgn.dev"
}

output "apprunner_custom_domain_validation_records" {
  value       = aws_apprunner_custom_domain_association.pwbot.certificate_validation_records
  description = "The DNS records to validate the custom domain"
}