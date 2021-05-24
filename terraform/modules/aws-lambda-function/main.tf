resource "aws_iam_role" "function_role" {
  count = var.create ? 1 : 0
  name  = "function-role-${var.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = var.tags
}

resource "aws_lambda_function" "this" {
  count            = var.create ? 1 : 0
  function_name    = var.name
  filename         = var.dist_file
  role             = aws_iam_role.function_role[0].arn
  runtime          = var.runtime
  handler          = var.handler
  source_code_hash = filebase64sha256(var.dist_file)
  memory_size      = var.memory_size
  timeout          = var.timeout
  tags             = var.tags
}
