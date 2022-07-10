output "kubernetes-private-ip" {
  value = aws_instance.kubernetes.private_ip
}


output "bastion-host-public_ip" {
  value = aws_instance.bastion.public_ip
}
