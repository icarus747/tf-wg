output "public_ip" {
  value       = aws_instance.vpnserver.public_ip
  description = "EC2 Public IP"
}

output "private_key" {
  value     = module.tls.private_key_out
  sensitive = true
}

output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
}