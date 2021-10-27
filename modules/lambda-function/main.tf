locals {
  filepath = "/tmp/aws-lambda-go.zip"
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "../../toshl-email-autosync/bin"
  output_path = local.filepath
}

resource "aws_lambda_function" "sync" {
  function_name                  = "toshl-sync"
  filename                       = local.filepath
  handler                        = "main"
  source_code_hash               = "data.archive_file.zip.output_base64sha256"
  role                           = aws_iam_role.iam_for_lambda.arn
  runtime                        = "go1.x"
  memory_size                    = 128
  timeout                        = 150
  reserved_concurrent_executions = 1
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "schedule"
  description         = "Fires every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_schedule" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.sync.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sync.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_iam_role_policy" "iam_dynamodb_policy" {
  name = "iam_dynamodb_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListAndDescribe",
      "Effect": "Allow",
      "Action": [
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SpecificTable",
      "Effect": "Allow",
      "Action": [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem"
      ],
      "Resource": "${var.toshl-table-arn}"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda-loggroup" {
  name = "/aws/lambda/${aws_lambda_function.sync.function_name}"

  retention_in_days = 1
}