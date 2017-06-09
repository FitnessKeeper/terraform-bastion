output "ssh_user" {
  value = "${module.bastion.ssh_user}"
}

output "security_group_id" {
  value = ["${module.bastion.security_group_id}"]
}

output "eip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "fqdn" {
  value = "${aws_route53_record.bastion.fqdn}"
}
