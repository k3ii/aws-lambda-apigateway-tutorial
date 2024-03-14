resource "aws)api_gateway_rest_api" "api_gateway" {
  name = "DynamoDBOperations"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = api_gateway_rest_api.api_gateway.id
  parent_id   = api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "DynamoDBManager"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/DynamoDBManager"
}
