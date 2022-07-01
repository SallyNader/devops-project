# Generate new private key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "key"
  public_key = trimspace(tls_private_key.key.public_key_openssh)
}


resource "local_file" "ssh_key" {
  filename = "mykey.pem"
  file_permission = "0400"
  content = tls_private_key.key.private_key_pem
}


output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}