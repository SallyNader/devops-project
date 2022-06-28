# Generate new private key
resource "tls_private_key" "key" {
  algorithm = "RSA"
   rsa_bits  = 4096
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "efs-key"
  public_key = tls_private_key.key.public_key_openssh
}

# Saving Key Pair for ssh login for Client if needed
resource "null_resource" "save_key_pair" {
  provisioner "local-exec" {
    command = "echo  ${tls_private_key.key.private_key_pem} > mykey.pem"
  }
}


output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}