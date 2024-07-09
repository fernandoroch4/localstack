resource "aws_dynamodb_table" "catalog" {
  name         = "catalog"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "key"

  attribute {
    name = "key"
    type = "S"
  }
}
