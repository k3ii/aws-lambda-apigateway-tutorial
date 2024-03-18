resource "aws_iam_policy" "lambda_apigateway_policy" {
  name = "lambda-apigateway-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow"
        "Resource" : "*",
      }
    ]
  })
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-apigateway-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_apigateway_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "LambdaFunctionOverHttps.py"
  output_path = "function.zip"
}

resource "aws_lambda_function" "lambda_function_over_https" {
  function_name    = "LambdaFunctionOverHttps"
  handler          = "LambdaFunctionOverHttps.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
  runtime          = "python3.9"
}
