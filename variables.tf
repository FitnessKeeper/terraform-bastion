variable "allowed_cidr" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "A list of CIDR Networks to allow ssh access to."
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of Security Group ID's to allow access to."
}

variable "additional_user_data_script" {
  default = ""
}

variable "ami" {
  default = ""
}

variable "aws_key_name" {
}

variable "dns_zone" {
  description = "route53 zone: ex. foo.example.com"
}

variable "enable_eip" {
  description = "Boolean to determine if a EIP is assigned to the bastion, set to false if you want an internal bastion host"
  default     = true
}

variable "env" {
}

variable "identifier" {
  type        = string
  description = "Generic identifier, intended as a replacement for env (default '')"
  default     = ""
}

variable "hostname" {
  description = "DNS Hostname for the bastion host. creates $${hostname}.$${dns_zone}"
}

variable "keys_update_frequency" {
  description = "How often to update keys. A cron timespec or an empty string to turn off (default)"
  default     = ""
}

variable "region" {
  default     = "us-east-1"
  description = "AWS Region, defaults to us-east-1"
}

variable "s3_bucket_name" {
  default     = false
  description = "Defaults to false, Add bucket name if we want to use keys ex. public-keys-demo-bucket"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ID's use to place the bastion instance"
}

variable "vpc_id" {
}
