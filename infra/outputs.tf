output "sqs_queue_url" {
  value = aws_sqs_queue.image_queue.id
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_sqs_processor.arn
}
