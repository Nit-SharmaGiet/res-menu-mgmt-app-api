output "db_host" {
  value = aws_db_instance.main.address
}


#bastion outputs for public dns
output "bastion_host" {
  value = aws_instance.bastion.public_dns
}
