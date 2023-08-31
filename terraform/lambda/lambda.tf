provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_iam_role" "extractor_lambda_role" {
  name = "dh-event-extractor-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "extractor_policy_attachment" {
  role       = aws_iam_role.extractor_lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.extractor_lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_function" "event_extractor_lambda" {
  function_name    = "dh-event-extractor"
  role             = aws_iam_role.extractor_lambda_role.arn
  handler          = "handler.lambda_handler"
  filename         = "extractor.zip"
  source_code_hash = filebase64sha256("extractor.zip")
  runtime          = "python3.9"

  environment {
    variables = {
      REGION = var.region
    }
  }
}

data "aws_sqs_queue" "sqs_queue" {
  name = "dh-events"
}

resource "aws_lambda_event_source_mapping" "extractor_event_source_mapping" {
  event_source_arn = data.aws_sqs_queue.sqs_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.event_extractor_lambda.arn
  batch_size       = 1
}