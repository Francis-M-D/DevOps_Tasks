
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "hyderabad"
  region = "ap-south-2"
}

# Choosing the OS Type to use

data "aws_ami" "ubuntu_mumbai" {
  provider    = aws.mumbai
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu_hyderabad" {
  provider    = aws.hyderabad
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 Instance Creation

resource "aws_instance" "mumbai_ec2" {
  provider      = aws.mumbai
  ami           = data.aws_ami.ubuntu_mumbai.id
  instance_type = "t3.micro"

  tags = {
    Name = "Ubuntu-Mumbai"
  }
}

resource "aws_instance" "hyderabad_ec2" {
  provider      = aws.hyderabad
  ami           = data.aws_ami.ubuntu_hyderabad.id
  instance_type = "t3.micro"

  tags = {
    Name = "Ubuntu-Hyderabad"
  }
}

# Outputs

output "mumbai_public_ip" {
  value = aws_instance.mumbai_ec2.public_ip
}

output "hyderabad_public_ip" {
  value = aws_instance.hyderabad_ec2.public_ip
}
