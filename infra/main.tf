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
  region = "eu-west-1"
}

resource "aws_sqs_queue" "image_queue" {
  name                        = "image-processing-queue"
  visibility_timeout_seconds  = 60
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

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
  name = "lambda_sqs_policy"

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
        Resource = "arn:aws:s3:::pgr301-couch-explorers/*"
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
  function_name = "lambda-sqs-processor"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_sqs.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.image_queue.id
      S3_BUCKET     = "pgr301-couch-explorers"
      BUCKET_NAME   = "pgr301-couch-explorers"
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
