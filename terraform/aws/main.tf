provider "aws" {
  region = "us-east-1"
}

resource "aws_amplify_app" "pwbot" {
  name          = "pwbot"
  repository    = "https://github.com/jgnovakdev/password-generator-frontend.git"
  access_token = file("${path.module}/../../.env.github_oauth_token")
  environment_variables = {
    REACT_APP_API_URL  = "https://ok1nscb8e2.execute-api.us-east-1.amazonaws.com/prod/passwords/"
  }
  build_spec    = <<EOF
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - yarn install
    build:
      commands:
        - yarn build
  artifacts:
    baseDirectory: build
    files:
      - '**/*'
EOF
}

resource "aws_amplify_branch" "pwbot" {
  app_id      = aws_amplify_app.pwbot.id
  branch_name = "main"
}


output "amplify_app_url" {
  value = "https://${aws_amplify_app.pwbot.default_domain}"
}