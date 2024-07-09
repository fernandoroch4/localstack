data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "dynamodb:PutItem",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda"
  path        = "/"
  description = "IAM policy for a lambda"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "catalog"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "catalog" {
  type        = "zip"
  source_dir  = "../src/catalog"
  output_path = "../src/catalog.zip"
}

resource "aws_lambda_function" "catalog" {
  filename      = "../src/catalog.zip"
  function_name = "catalog"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "catalog.main"
  timeout       = 10
  memory_size   = 128
  architectures = ["arm64"]

  source_code_hash = data.archive_file.catalog.output_base64sha256

  runtime = "python3.12"

  environment {
    variables = {
      CATALOG_TABLE = aws_dynamodb_table.catalog.id
    }
  }
}

data "archive_file" "catalog_queue" {
  type        = "zip"
  source_dir  = "../src/catalog-queue"
  output_path = "../src/catalog-queue.zip"
}

resource "aws_lambda_function" "catalog_queue" {
  filename      = "../src/catalog-queue.zip"
  function_name = "catalog-queue"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "catalog-queue.main"
  timeout       = 10
  memory_size   = 128
  architectures = ["arm64"]

  source_code_hash = data.archive_file.catalog_queue.output_base64sha256

  runtime = "python3.12"

  environment {
    variables = {
      CATALOG_TABLE = aws_dynamodb_table.catalog.id
    }
  }
}

resource "aws_lambda_permission" "catalog" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.catalog.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.temp.arn
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.catalog_queue.arn
}
