resource "aws_instance" "kubernetes" {
  ami                    = "ami-0cff7528ff583bf9a"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.kubernetes.id]
  subnet_id              = aws_subnet.private-subnet.id

  tags = {
    name = "kubernetes"
  }
  key_name = aws_key_pair.deployer.key_name

  user_data = <<EOF
    #!/bin/bash
       sudo amazon-linux-extras install ansible2
    EOF

}

resource "aws_security_group" "kubernetes" {
  name        = "kubernetes allow bastion host"
  description = "Allow only bastion host to access kubernetes instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow ssh from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-host.id]
  }
  egress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-host.id]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

output "kubernetes-private-ip" {
  value = aws_instance.kubernetes.private_ip
}
