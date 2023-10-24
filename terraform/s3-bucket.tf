resource "aws_s3_bucket" "s3_bucket" {
  bucket = "snowflake-ep-hackathon"
  tags = {
    Name        = "enrique-plata-snowflake-hackathon"
    Environment = "DEV"
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name        = "snowflake-ep-hackathon-s3-policy"
  description = "Policy for bucket snowflake-ep-hackathon"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws:s3:::snowflake-ep-hackathon/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::snowflake-ep-hackathon",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "*"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "s3_role" {
  name = "snowflake-ep-hackathon-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::833695691939:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "0000"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_role_attachment" {
  policy_arn = aws_iam_policy.bucket_policy.arn
  role       = aws_iam_role.s3_role.name
}