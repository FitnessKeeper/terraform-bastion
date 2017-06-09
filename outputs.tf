output "ssh_user" {
  value = "${module.bastion.ssh_user}"
}

output "security_group_id" {
  value = ["${module.bastion.security_group_id}"]
}
