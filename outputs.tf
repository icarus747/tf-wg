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

output "Next_Steps" {
  value = "Connect to your EC2 on port 5000 and setup a WG clinet. Apply settings and reboot the WG container (by running TF apply again, or manually restarting the container)."
}