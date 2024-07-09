resource "aws_s3_bucket" "temp" {
  bucket = "temp"
}

resource "aws_s3_bucket_notification" "queue" {
  bucket = aws_s3_bucket.temp.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = "queue/"
  }
}

resource "aws_s3_bucket_notification" "default" {
  bucket = aws_s3_bucket.temp.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.catalog.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "default/"
  }

  depends_on = [aws_lambda_permission.catalog]
}
