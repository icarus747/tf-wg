variable "region" {
  type        = string
  description = "The AWS region"
  default     = "us-east-1"
}

variable "my_aws_key" {
  type        = string
  description = "AWS key to SSH into EC2 instances"
  default     = "mykey.pem"
}

variable "my_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

# variable "cloudflare_api_token" {
#   type        = string
#   description = "Cloudflare api token for domains."
#   default     = "some_value"
# }

# variable "cloudflare_zone_id" {
#   type        = string
#   description = "Cloudflare domain zone id."
#   default     = "some_value"
# }

# variable "SERVERURL" {
#   type        = string
#   description = "Domain Name for WireGuard"
# }