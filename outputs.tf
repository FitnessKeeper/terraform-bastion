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
  value = "${var.enable_eip ? join("", aws_route53_record.bastion.*.fqdn) : "not created"}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.bastion.arn}"
}

output "iam_instance_profile_arn" {
  value = "${aws_iam_instance_profile.bastion.arn}"
}
