provider "aws" {
  region = "us-east-1"
}

resource "aws_secretsmanager_secret" "opensky_credentials" {
  name        = "opensky_credentials"
  description = "OpenSky Network credentials for the KQ flight notifier"
}

resource "aws_secretsmanager_secret_version" "opensky_credentials_version" {
  secret_id     = aws_secretsmanager_secret.opensky_credentials.id
  secret_string = jsonencode({
    username = var.opensky_username,
    password = var.opensky_password
  })
}

resource "aws_sns_topic" "kq_flight_notifications" {
  name = "kq-flight-notifications"
}

resource "aws_lambda_function" "kq_flight_notifier" {
  function_name = "kq-flight-notifier"
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = "python3.11"
  timeout       = 15
  handler       = "lambda_function.lambda_handler"
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.kq_flight_notifications.arn
      SECRET_NAME   = aws_secretsmanager_secret.opensky_credentials.name
    }
  }
  code {
    filename = "lambda_function.zip"
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "kq-flight-notifier-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "kq-flight-notifier-policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "sns:Publish",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "kq_flight_schedule" {
  name                = "kq-flight-check-schedule"
  description         = "Trigger the KQ flight notifier every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "kq_flight_lambda_trigger" {
  rule = aws_cloudwatch_event_rule.kq_flight_schedule.name
  arn  = aws_lambda_function.kq_flight_notifier.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowCloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kq_flight_notifier.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.kq_flight_schedule.arn
}
