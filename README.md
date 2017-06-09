Bastion Host terraform module
===========

Terraform module which wraps and manages tf_aws_bastion_s3_keys module.


This module

- Deploys an external facing Bastion host and attached EIP
- Deploys an *internal* facing Bastion host without an attached EIP


----------------------
#### Required
- `aws_key_name`
- `dns_zone` - route53 zone: ex. foo.example.com
- `env` - dev/staging/prod
- `hostname` - DNS Hostname for the bastion host. creates ${hostname}.${dns_zone}
- `subnet_ids` - Subnet ID's use to place the bastion instance
- `vpc_id` - The... you know... VPC ID...


#### Optional

- `allowed_cidr` - A list of CIDR Networks to allow ssh access to. Defaults to 0.0.0.0/0
- `allowed_security_groups` - A List of Security Groups to Allow access to. Defaults to Empty List
- `additional_user_data_script` - Additional user_data scripts content
- `allowed_cidr`
- `ami` - AMI to deploy, defaults to searching for "^rk-bastion-\\d.+"
- `enable_eip` - Boolean to determine if a EIP is assigned to the bastion, set to false if you want an internal bastion host
- `keys_update_frequency` - How often to update keys. A cron timespec or an empty string to turn off (default)
- `region` - AWS Region, defaults to us-east-1
- `s3_bucket_name` - Defaults to false, Add bucket name if we want to use keys ex. public-keys-demo-bucket

Usage
-----

```hcl
# Public Bastion Host Example
module "bastion_host" {
  source       = "../modules/terraform-bastion"
  aws_key_name = "${var.aws_key_name}"
  dns_zone     = "${data.aws_route53_zone.rkcloud.name}"
  env          = "${var.env}"
  hostname     = "bastion.${var.stack}-${var.env}-infra"
  vpc_id       = "${module.vpc.vpc_id}"
  additional_user_data_script = "${data.template_file.consul_agent_json.rendered}"
  subnet_ids   = "${module.vpc.public_subnets}"
}

# Private Bastion Host Example
module "dba_bastion_host" {
  source       = "../modules/terraform-bastion"
  aws_key_name = "${var.aws_key_name}"
  dns_zone     = "${data.aws_route53_zone.rkcloud.name}"
  env          = "${var.env}"
  hostname     = "bastion1.${var.stack}-${var.env}-infra"
  vpc_id       = "${module.vpc.vpc_id}"
  additional_user_data_script = "${data.template_file.consul_agent_json.rendered}"
  enable_eip   = false
  allowed_cidr = ["10.0.0.0/8"]
  subnet_ids   = "${module.vpc.private_subnets}"
}

```

Outputs
=======

- `ssh_user -
- `security_group_id` -

Authors
=======

[Tim Hartmann](https://github.com/tfhartmann)

License
=======

[MIT License](LICENSE)
