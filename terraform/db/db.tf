provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_dynamodb_table" "dh_events_table" {
  name           = "dh-events"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "sensorId"
  range_key       = "timestamp"

  attribute {
    name = "sensorId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

resource "aws_iam_user" "dh_core_user" {
  name = "dh-core-user"
}

data "aws_iam_policy_document" "dh_core_user_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account}:table/dh-events",
    ]
  }
}

resource "aws_iam_user_policy" "dh_core_user_policy" {
  name   = "dh-core-user-policy"
  user   = aws_iam_user.dh_core_user.name
  policy = data.aws_iam_policy_document.dh_core_user_policy_document.json
}