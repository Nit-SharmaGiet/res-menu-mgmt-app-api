#refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami.html for below code template

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name = "name"
    #goto ec2->launch instance->get the AMI ID (ami-0a1179631ec8933d7) then
    #goto AMI->search this in public images->get the ID name (amzn2-ami-kernel-5.10-hvm-2.0.20240412.0-x86_64-gp2)->use here
    #paisa bach gaya
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240412.0-x86_64-gp2"]

  }
  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro"
  user_data            = file("./templates/bastion/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name             = var.bastion_key_name

  #assign this instance in a subnet public
  subnet_id = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-bastion"
      }
    )
  )
}

####################################################################################
#create a role by referring from instance-profile-policy.json
resource "aws_iam_role" "bastion" {
  name               = "${local.prefix}-bastion"
  assume_role_policy = file("./templates/bastion/instance-profile-policy.json")

  tags = local.common_tags
}

#attach policy to iam role
resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#attach instance profile to the iam role.
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}
