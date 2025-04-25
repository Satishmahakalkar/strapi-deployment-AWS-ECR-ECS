output "alb_url" {
  value = aws_lb.strapi_alb.dns_name
}
