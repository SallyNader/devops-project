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



