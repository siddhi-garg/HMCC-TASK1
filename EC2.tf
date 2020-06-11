provider "aws" {
  region     = "ap-south-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

resource "aws_key_pair" "Keyfromterra" {
	key_name = "TerraKey"
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_security_group" "SGfromterra" {
  name        = "SGfromterra"
  description = "Allow TCP inbound traffic"
  vpc_id      = "vpc-369a875e"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
	from_port = 0
 	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "TerraSG"
  }
}


resource "aws_instance" "Terra-OS" {
	ami = "ami-0447a12f28fddb066"
	instance_type = "t2.micro"
	key_name = "TerraKey"
	security_groups = ["SGfromterra"]
	user_data = <<-EOF
		#!/bin/bash
		sudo yum install httpd -y
		sudo systemctl start httpd
		sudo systemctl enable httpd
		sudo yum install git -y
		mkfs.ext4 /dev/df1
		mount /dev/df1 /var/www/html
		cd /var/www/html
		git clone https://github.com/siddhi-garg/HMCC-TASK1.git
	EOF
	tags = { 
		  Name = "Terra-OS"
        }
}

resource "aws_ebs_volume" "Terra-EBS" {
  availability_zone = aws_instance.Terra-OS.availability_zone
  size              = 1

  tags = {
    Name = "Terra-EBS"
  }
}


resource "aws_volume_attachment" "EBSattach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.Terra-EBS.id
  instance_id = aws_instance.Terra-OS.id
}


resource "aws_s3_bucket" "terra-bucket-s3" {
  bucket = "terra-bucket-s3"
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket = "${aws_s3_bucket.terra-bucket-s3.id}"

  block_public_acls   = true
  block_public_policy = true
}