# Create an S3 bucket to store the Lambda function code
resource "aws_s3_bucket" "lambda_bucket" {
  bucket_prefix = "makuta-lambda-bucket-for-dev"

  tags = {
    Name        = "MakutaLambdaBucket"
    Environment = "Dev"
  }
}

# Upload the Lambda code to S3 bucket
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "${path.module}/my_lambda_function/lambda_function.zip"
  acl    = "private"

 

  tags = {
    Name        = "LambdaFunctionCode"
    Environment = "Dev"
  }
}

# Create an IAM Role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create an IAM Role for Lambda execution
resource "aws_iam_role" "lambda_execution_dev_role" {
  name               = "lambda_execution_dev_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Define permissions for the Lambda function
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*",
        "s3:*",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

# Create the Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "makuta_dev_LF"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_execution_role.arn

  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = aws_s3_object.lambda_code.key

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  timeout     = 30
  memory_size = 128
}


# Create a security group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LambdaSecurityGroup"
  }
}