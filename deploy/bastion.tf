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
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = merge(
    local.common_tags,
    tomap({
        "Name" = "${local.prefix}-bastion"
    }
  )
  )


}

