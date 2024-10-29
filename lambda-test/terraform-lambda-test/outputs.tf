output "website_url" {
  description = "url of the website"
  value = module.website.website_url
}

output "api_endpoint" {
  description = "api gateway endpoint url"
  value = module.api_gateway.api_endpoint
}

output "lambda_env_vars" {
  value = module.github_manifest_lambda.debug_env_vars
  sensitive = true
}