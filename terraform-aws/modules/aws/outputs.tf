output "app_url" {
  value       = "${aws_lb.app_lb.dns_name}"
  description = "URL of the application load balancer"
}