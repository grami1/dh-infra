provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_sqs_queue" "sqs_queue" {
  name                      = "dh-events"
  max_message_size          = 2048
  message_retention_seconds = 86400
}


resource "aws_iam_role" "iot_core_sqs_role" {
  name = "iot-core-sqs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "iot_core_sqs_policy_document" {
  statement {
    effect  = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.sqs_queue.arn]
  }
}

resource "aws_iam_policy" "iot_core_sqs_policy" {
  name        = "iot-core-sqs-policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.iot_core_sqs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iot_core_sqs_policy_attachment" {
  role       = aws_iam_role.iot_core_sqs_role.id
  policy_arn = aws_iam_policy.iot_core_sqs_policy.arn
}

resource "aws_iot_topic_rule" "sqs_rule" {
  name        = "iot_core_sqs_rule"
  enabled     = true
  sql         = "SELECT * FROM '${var.topic}'"
  sql_version = "2016-03-23"

  sqs {
    role_arn   = aws_iam_role.iot_core_sqs_role.arn
    queue_url  = "https://sqs.${var.region}.amazonaws.com/${var.account}/${aws_sqs_queue.sqs_queue.name}"
    use_base64 = false
  }
}