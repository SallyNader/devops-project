# Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "efs"
  tags = {
    Name = "efs"
  }
}

# Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-subnet.id
  security_groups = [aws_security_group.bastion-host.id]
}

resource "null_resource" "attach_efs_bastion"  {
  depends_on = [
    aws_efs_mount_target.mount,
  ]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key =  tls_private_key.key.private_key_pem
    host     = aws_instance.bastion.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /project",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /project"
     
    ]
  }
}

