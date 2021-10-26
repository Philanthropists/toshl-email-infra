output "url" {
  value = "${aws_api_gateway_deployment.time_deploy.invoke_url}${aws_api_gateway_resource.resource.path}"
}