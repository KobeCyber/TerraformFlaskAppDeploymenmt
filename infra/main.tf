provider "aws" {
  region = var.region
}

resource "aws_security_group" "flask_sg" {
  name        = "flask_sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "flask_ec2" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -aG docker ec2-user
              cd /home/ec2-user
              yum install git -y
              git clone https://github.com/KobeCyber/TerraformFlaskAppDeploymenmt.git flask-app
              cd /flask-app/app
              docker build -t flask-app .
              docker run -d -p 80:5000 flask-app
              EOF

  tags = {
    Name = "FlaskApp"
  }
}
