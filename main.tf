locals {
  identifier = length(var.identifier) > 0 ? "${var.identifier}.${var.dns_zone}" : var.env
}

data "aws_route53_zone" "zone" {
  name = var.dns_zone
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Tier = "public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Tier = "private"
  }
}

data "aws_ami" "bastion" {
  most_recent = true
  name_regex  = "^rk-bastion-\\d.+"
  owners      = ["self"]
}

data "template_file" "bastion_user_data" {
  template = file("${path.module}/files/user_data/bastion.sh")

  vars = {
    svc_name = replace(var.hostname, "/\\..+$/", "") # Strip dot hostnames so foo.bar becomes foo
    eip      = var.enable_eip ? aws_eip.bastion.public_ip : ""
    eip_id   = var.enable_eip ? aws_eip.bastion.id : ""
    env      = var.env
    region   = var.region
  }
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:AllocateAddress",
      "ec2:DescribeInstances",
      "ec2:AssociateAddress",
    ]

    resources = ["*"]
  }
}

# Since we *must* create an EIP, we do, but we don't attach it to the bastion
resource "aws_eip" "bastion" {
  vpc = true
}

# Publish DNS Record with Public IP
resource "aws_route53_record" "bastion" {
  count   = var.enable_eip ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.zone.name}"
  type    = "A"
  ttl     = "3600"
  records = [aws_eip.bastion.public_ip]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.identifier}"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role" "bastion" {
  name               = "${local.identifier}-bastion-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy" "bastion" {
  name   = "${local.identifier}-bastion-policy"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.role_policy.json
}

module "bastion" {
  source                      = "git@github.com:asicsdigital/terraform-aws-bastion-s3-keys.git?ref=v3.0.0"
  name                        = "${var.hostname}.${data.aws_route53_zone.zone.name}"
  ssh_user                    = "ec2-user"
  instance_type               = "t2.micro"
  ami                         = var.ami == "" ? format("%s", data.aws_ami.bastion.id) : var.ami
  region                      = var.region
  key_name                    = var.aws_key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  s3_bucket_name              = var.s3_bucket_name
  vpc_id                      = data.aws_vpc.vpc.id
  subnet_ids                  = var.subnet_ids
  keys_update_frequency       = var.keys_update_frequency
  eip                         = var.enable_eip ? aws_eip.bastion.public_ip : "" # We *must* create an EIP resource for this conditional to work, even if enable_eip is set to false
  additional_user_data_script = "${data.template_file.bastion_user_data.rendered}${var.additional_user_data_script}"
  allowed_cidr                = var.allowed_cidr
  allowed_security_groups     = var.allowed_security_groups
}
