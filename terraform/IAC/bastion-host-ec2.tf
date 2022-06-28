resource "aws_instance" "bastion" {
  ami                    = "ami-0cff7528ff583bf9a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastion-host.id]
  subnet_id              = aws_subnet.public-subnet.id
  availability_zone = "us-east-1a"

  tags = {
    name = "bastion-host"
  }
  key_name = aws_key_pair.deployer.key_name
}

resource "aws_security_group" "bastion-host" {
  name        = "bastion-host Allow web traffic"
  description = "Allow Web inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow ssh from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow http from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow TLS from everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


output "bastion-host-public_ip" {
  value = aws_instance.bastion.public_ip
}

