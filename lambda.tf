resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-apigateway-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1428341300017",
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
        "Sid" : "",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
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

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "LambdaFunctionOverHttps.py"
  output_path = "function.zip"
}

resource "aws_lambda_function" "LambdaFunctionOverHttps" {
  function_name    = "LambdaFunctionOverHttps"
  handler          = "handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256
}
