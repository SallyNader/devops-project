resource "aws_instance" "kubernetes" {
  ami                    = "ami-0cff7528ff583bf9a"
  instance_type          = "t2.micro"
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
    description = "Allow ssh from bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "kubernetes-private-ip" {
  value = aws_instance.kubernetes.private_ip
}