
# Output of the s3_role ARN
output "s3_role_arn" {
  description = "The ARN of the s3_role"
  value       = aws_iam_role.s3_role.arn
}
