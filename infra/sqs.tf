
data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:temp-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.temp.arn]
    }
  }
}

resource "aws_sqs_queue" "queue" {
  name   = "temp-queue"
  policy = data.aws_iam_policy_document.queue.json
}
