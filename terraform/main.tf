terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

resource "random_string" "instance_suffix" {
  length    = 4
  special   = false
  upper     = false
  numeric   = true
  lower     = true
}

provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

resource "aws_lightsail_instance" "wg_tunnel" {
  name                = "wg_tunnel-${random_string.instance_suffix.result}"
  availability_zone   = "us-east-2c"
  blueprint_id        = "ubuntu_22_04"
  bundle_id           = "nano_2_0"

  user_data           = <<-EOF
    echo "${var.pubkey}" >> /home/${var.ssh_username}/.ssh/authorized_keys
    chown -R ${var.ssh_username}:${var.ssh_username} /home/${var.ssh_username}/.ssh
    chmod 600 /home/${var.ssh_username}/.ssh/authorized_keys
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF
}

resource "aws_lightsail_instance_public_ports" "ssh" {
  instance_name = aws_lightsail_instance.wg_tunnel.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    protocol  = "udp"
    from_port = 51820
    to_port   = 51820
    cidrs     = ["0.0.0.0/0"]
  }
}


locals {
  templatevars = {
    init_public_key   = var.pubkey,
    init_ssh_username = var.ssh_username
  }
}

variable "pubkey" {
  type        = string
}

variable "ssh_username" {
  type        = string
  description = "Username to use"
  default     = "ubuntu"
}

output "public_ip" {
  value = aws_lightsail_instance.wg_tunnel.public_ip_address
}
