data "aws_region" "current" {}

resource "aws_lambda_function" "sync" {
  function_name                  = "toshl-sync"
  image_uri                      = var.ecr_image_uri
  package_type                   = "Image"
  role                           = aws_iam_role.iam_for_lambda.arn
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

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sync.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "iam_dynamodb_policy" {
  name = "iam_dynamodb_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = data.aws_iam_policy_document.iam_dynamodb_policy_document.json
}

data "aws_iam_policy_document" "iam_dynamodb_policy_document" {
  version = "2012-10-17"

  statement {
    sid    = "ListAndDescribe"
    effect = "Allow"
    actions = [
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SpecificTable"
    effect = "Allow"
    actions = [
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
    ]
    resources = [var.toshl-table-arn]
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.sync.function_name}"

  retention_in_days = 1
}

data "aws_iam_policy_document" "lambda_exec_role_policy_without_createloggroup" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_exec_role_without_createloggroup" {
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_exec_role_policy_without_createloggroup.json
}
