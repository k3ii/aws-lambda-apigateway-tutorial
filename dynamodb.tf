resource "aws_dynamodb_table" "lambda_apigateway" {
  name           = "lambda-apigateway"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
