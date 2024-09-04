terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0" # Use the latest 3.x version
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
      }
      image_identifier      = "${data.aws_ecr_repository.app_repo.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }
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
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_service_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
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

# output ecr repository
output "aws_ecr_repository" {
  value = aws_ecr_repository.app.repository_url
}

# output apprunner_service_url
output "apprunner_service_url" {
  value = aws_apprunner_service.pwbot.service_url
}

# output cname record
output "aws_route53_record" {
  value = aws_route53_record.pwbot.name
}

# output custom_domain
output "custom_domain" {
  value = aws_apprunner_custom_domain_association.pwbot.domain_name
}