terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }

  backend "s3" {
    bucket         = "pgr301-2024-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

resource "aws_sqs_queue" "image_queue" {
  name                        = "image-processing-queue-Kandidat57"
  visibility_timeout_seconds  = 60
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role-Kandidat57"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_sqs_policy-Kandidat57"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.image_queue.arn
      },
      {
        Action   = "s3:PutObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Action   = "logs:*",
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "bedrock:InvokeModel",
        Effect   = "Allow",
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda_sqs_processor" {
  function_name = "lambda-sqs-processor-Kandidat57"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_sqs.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.image_queue.id
      S3_BUCKET     = var.bucket_name
      BUCKET_NAME   = var.bucket_name
    }
  }

  filename         = "lambda_sqs.zip"
  source_code_hash = filebase64sha256("lambda_sqs.zip")
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.lambda_sqs_processor.arn
  batch_size       = 10
}

resource "aws_sns_topic" "sqs_alarm_topic" {
  name = "sqs_alarm_topic-Kandidat57"
}

resource "aws_sns_topic_subscription" "sqs_alarm_email_subscription" {
  topic_arn = aws_sns_topic.sqs_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_approximate_age_alarm" {
  alarm_name          = "SQS-ApproximateAgeAlarm-Kandidat57"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 300

  dimensions = {
    QueueName = aws_sqs_queue.image_queue.name
  }

  alarm_description = "Trigges når ApproximateAgeOfOldestMessage overstiger 300 sekunder."
  actions_enabled   = true
  alarm_actions     = [aws_sns_topic.sqs_alarm_topic.arn]
}
