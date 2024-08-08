provider "aws" {
  region = "us-west-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0603cb4546aa25a8b"
}

variable "key_name" {
  description = "ssh key to connect"
}

variable "key_file" {
  description = "ssh key to connect"
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "WebServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y ansible"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.key_file)
    host        = self.public_ip
  }
}

# Copy HTML files to the instance
resource "null_resource" "copy_html" {
  provisioner "file" {
    source      = "html/"
    destination = "/home/ubuntu/html/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_file)
      host        = aws_instance.web.public_ip
    }
  }
}

# Copy SQL file to the instance
resource "null_resource" "copy_sql" {
  provisioner "file" {
    source      = "aws_provisioning.sql"
    destination = "/home/ubuntu/aws_provisioning.sql"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_file)
      host        = aws_instance.web.public_ip
    }
  }
}

# Run Ansible playbook to setup Apache and MySQL
resource "null_resource" "run_ansible" {
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook apache_mysql_setup.yml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_file)
      host        = aws_instance.web.public_ip
    }
  }

  depends_on = [aws_instance.web, null_resource.copy_html, null_resource.copy_sql]
}
