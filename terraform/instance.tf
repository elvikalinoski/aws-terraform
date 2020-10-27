# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  shared_credentials_file = ".aws/credentials" # A pasta .aws criar em um diretorio a parte para não enviar para GIT
  profile = "usuario"
}

resource "aws_instance" "usuario" {
  ami = "ami-05cf2c352da0bfb2e" # Ubuntu 20.04 LTS - amd64
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
  security_groups = ["${aws_security_group.allow_ssh.name}"]
}

# Enviando a chave de acesso SSH
resource "aws_key_pair" "my-key" {
  key_name = "my-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Regra de entrada e saida
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "SG de teste"

    dynamic "ingress" {
      for_each = var.default_ingress
        content {
          description = ingress.value["description"]
          from_port   = ingress.key
          to_port     = ingress.key
          protocol    = "tcp"
          cidr_blocks = ingress.value["cidr_blocks"]
        }
    }

    dynamic "egress" {
      for_each = var.default_egress
        content {
          description = egress.value["description"]
          from_port   = egress.key
          to_port     = egress.key
          protocol    = -1
          cidr_blocks = egress.value["cidr_blocks"]
        }
    }
}

output "instance_ips" {
  value = ["${aws_instance.usuario.public_dns}"]
}