output "parameter_names" {
  value = keys(aws_ssm_parameter.this)
}

