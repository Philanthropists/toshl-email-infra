locals {
    filepath = "/tmp/aws-lambda-go.zip"
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir = "../../toshl-email-autosync/bin"
  output_path = local.filepath
}

resource "aws_lambda_function" "sync" {
  function_name    = "toshl-sync"
  filename         = local.filepath
  handler          = "main"
  source_code_hash = "data.archive_file.zip.output_base64sha256"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 10
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

resource "aws_api_gateway_rest_api" "api" {
  name = "time_api"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "time"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.sync.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sync.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "time_deploy" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "v1"

}
