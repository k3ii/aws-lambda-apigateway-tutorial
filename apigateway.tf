resource "aws_api_gateway_rest_api" "DynamoDBOperations" {
  name = "DynamoDBOperations"
}

resource "aws_api_gateway_resource" "DynamoDBManager" {
  rest_api_id = aws_api_gateway_rest_api.DynamoDBOperations.id
  parent_id   = aws_api_gateway_rest_api.DynamoDBOperations.root_resource_id
  path_part   = "DynamoDBManager"
}

resource "aws_api_gateway_method" "DynamoDBManagerPost" {
  rest_api_id   = aws_api_gateway_rest_api.DynamoDBOperations.id
  resource_id   = aws_api_gateway_resource.DynamoDBManager.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "LambdaIntegration" {
  rest_api_id = aws_api_gateway_rest_api.DynamoDBOperations.id
  resource_id = aws_api_gateway_resource.DynamoDBManager.id
  http_method = aws_api_gateway_method.DynamoDBManagerPost.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_over_https.invoke_arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_over_https.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.DynamoDBOperations.execution_arn}/*/POST/DynamoDBManager"
}

resource "aws_api_gateway_deployment" "v1_deployment" {
  depends_on = [
    aws_api_gateway_integration.LambdaIntegration
  ]

  rest_api_id = aws_api_gateway_rest_api.DynamoDBOperations.id
  stage_name  = "v1"
  lifecycle {
    create_before_destroy = true
  }
}
