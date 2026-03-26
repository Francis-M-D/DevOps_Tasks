# PROVIDERS (Multi-region)

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "hyderabad"
  region = "ap-south-2"
}

# FETCH LATEST UBUNTU AMI - MUMBAI

data "aws_ami" "ubuntu_mumbai" {
  provider    = aws.mumbai
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# FETCH LATEST UBUNTU AMI - HYDERABAD

data "aws_ami" "ubuntu_hyderabad" {
  provider    = aws.hyderabad
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# SECURITY GROUP - MUMBAI

resource "aws_security_group" "sg_mumbai" {
  provider = aws.mumbai

  name        = "allow_http_mumbai"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# SECURITY GROUP - HYDERABAD

resource "aws_security_group" "sg_hyderabad" {
  provider = aws.hyderabad

  name        = "allow_http_hyderabad"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# EC2 INSTANCE - MUMBAI

resource "aws_instance" "mumbai_ec2" {
  provider = aws.mumbai

  ami           = data.aws_ami.ubuntu_mumbai.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.sg_mumbai.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Mumbai"
  }
}

# EC2 INSTANCE - HYDERABAD

resource "aws_instance" "hyderabad_ec2" {
  provider = aws.hyderabad

  ami           = data.aws_ami.ubuntu_hyderabad.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.sg_hyderabad.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Hyderabad"
  }
}

# OUTPUTS

output "mumbai_public_ip" {
  value = aws_instance.mumbai_ec2.public_ip
}

output "hyderabad_public_ip" {
  value = aws_instance.hyderabad_ec2.public_ip
}
