provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}

resource "aws_security_group" "jenkins" {
  name = local.jenkins_default_name
  description = "Allow Jenkins inbound traffic"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2375
    to_port = 2375
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.jenkins_default_name
  }
}

resource "aws_key_pair" "jenkins_ec2_key" {
  key_name = "terraform_ec2_key"
  public_key = file("jenkins_ec2_key.pub")
}

resource "aws_instance" "jenkins_master" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"
  key_name = aws_key_pair.jenkins_ec2_key.key_name

  tags = {
    Name = "Jenkins Master"
  }

  security_groups = ["default", aws_security_group.jenkins.name]

  connection {
    host = aws_instance.jenkins_master.public_ip
    user = "ubuntu"
    private_key = file("jenkins_ec2_key")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }
}
