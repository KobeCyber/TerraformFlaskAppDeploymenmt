# VPC
resource "aws_vpc" "flask_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "flask-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "flask_igw" {
  vpc_id = aws_vpc.flask_vpc.id

  tags = {
    Name = "flask-igw"
  }
}

# Public Subnet
resource "aws_subnet" "flask_subnet" {
  vpc_id                  = aws_vpc.flask_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "flask-subnet"
  }
}

# Route Table
resource "aws_route_table" "flask_rt" {
  vpc_id = aws_vpc.flask_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flask_igw.id
  }

  tags = {
    Name = "flask-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "flask_rta" {
  subnet_id      = aws_subnet.flask_subnet.id
  route_table_id = aws_route_table.flask_rt.id
}

# Security Group (attach to new VPC)
resource "aws_security_group" "flask_sg" {
  name        = "flask_sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.flask_vpc.id

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

# EC2 Instance (in new subnet + SG)
resource "aws_instance" "flask_ec2" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.flask_subnet.id
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -aG docker ec2-user

              while (! docker info > /dev/null 2>&1); do
                echo "Waiting for Docker to start..."
                sleep 1
              done

              cd /home/ec2-user
              yum install git -y
              git clone https://github.com/KobeCyber/TerraformFlaskAppDeployment.git flask-app
              cd /home/ec2-user/flask-app/app
              docker build -t flask-app .
              docker run -d -p 80:5000 flask-app
              EOF

  tags = {
    Name = "FlaskApp"
  }
}
