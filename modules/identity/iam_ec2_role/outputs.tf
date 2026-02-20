output "instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.this.name
}

output "instance_profile_arn" {
  description = "EC2 instance profile ARN"
  value       = aws_iam_instance_profile.this.arn
}

output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}

