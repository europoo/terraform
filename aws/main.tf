## For apprenticeship
# will have to replace access key and secret key with your own
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "eu-west-2"
}

/*
  data "aws_security_group" "launch-wizard-3" {
    id = "sg-000b55ddd6e19298b"
  }


  resource "aws_instance" "demo1" {
    ami                         = var.ami
    instance_type               = "t2.micro"
    user_data_replace_on_change = true
    user_data                   = <<-EOF
          #!/bin/bash
          echo 'test' >> test.txt
          sudo apt-get update -y && sudo apt-get upgrade -y
          sudo apt install nginx -y
          sudo apt install wget -y
          EOF

    tags = {
      Name = "made by terraform"
    }

    key_name               = "terraform-mod5"
    vpc_security_group_ids = [data.aws_security_group.launch-wizard-3.id]
  }

  resource "aws_s3_bucket" "demo-bucket" {
    bucket = var.bucket_name
  }

  locals {
    project_name = "my project"
  }
*/

# lab4 resource list:

/*
  aws_instance
  Ami
  Instance type
  Key_name
  vpc_security_group_ids = []

  tags = lab4
  depends_on = [ssh_key]

  security_group:
  Name
  Description <- need this
  ingress rule

  aws_key_pair
  name
  public_key = 

  tls_private_key
  algorithm = rsa
  rsa_bits = 4096

  local_file
  filename = 
  content = 
  file_permission = '400'


  Output public ip

  ssh ubuntu@public_ip -i key-file

*/

/*
  Vpc:
  - cidr_block =

  subnets x2:
  - cidr_block = 
  - avilability_zone = 
  - map_public_ip_on_launch = 
  - vpc_id = 

  internet_gateway:
  - vpc_id

  security_group:
  - Name
  - Description
  - vpc_id
  - Ingress x3 (ssh, http, sql)
  - egress (from = 0, to = 0, protocol = -1, cidr_block = 0.0.0.0/0)

  route_table:
  - vpc_id

  aws_route:
  - route_table_id = 
  - destination_cidr_block = all ips
  - gateway_id =

  route_table_association x2:
  - subnet_id = 
  - route_table.id =

  aws_instance:
  - ami
  - type
  - vpc_id
  - key_name
  - security_group

*/

/*
  resource "aws_security_group" "daisy-sg" {
    name        = "daisy_sec_group"
    description = "Security group for daisy chain task"

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "daisy-chain-sg"
      Role = "public"
    }
  }

  resource "aws_key_pair" "TF_key" {
    key_name   = "TF_key"
    public_key = tls_private_key.rsa.public_key_openssh

  }

  resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits  = 4096

  }

  resource "local_file" "TF_key" {
    content         = tls_private_key.rsa.private_key_pem
    filename        = "TF_key"
    file_permission = "400"

  }


  resource "aws_instance" "daisy-chaining" {
    ami           = var.ami
    instance_type = var.instance_type

    tags = {
      Name = var.instance_name
    }

    key_name               = "TF_key"
    vpc_security_group_ids = [aws_security_group.daisy-sg.id]

  }
*/

resource "aws_vpc" "lab5-vpc" {
  cidr_block = "10.10.0.0/20"

  tags = {
    Name = "lab5-vpc"
  }
}

resource "aws_internet_gateway" "lab5-gw" {
  vpc_id = aws_vpc.lab5-vpc.id
}

resource "aws_subnet" "lab5-sn1" {
  cidr_block              = "10.10.0.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.lab5-vpc.id

  tags = {
    Name = "lab5-subnet1"
  }
}

resource "aws_subnet" "lab5-sn2" {
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.lab5-vpc.id

  tags = {
    Name = "lab5-subnet2"
  }
}

resource "aws_security_group" "lab5-sg" {
  name        = "lab5-sec-group"
  description = "lab5 security group"
  vpc_id      = aws_vpc.lab5-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab5-sec-group"
  }
}

resource "aws_route_table" "lab5-route-table" {
  vpc_id = aws_vpc.lab5-vpc.id
}

resource "aws_route" "lab5_in_access" {
  route_table_id         = aws_route_table.lab5-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab5-gw.id
}


resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.lab5-sn1.id
  route_table_id = aws_route_table.lab5-route-table.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.lab5-sn2.id
  route_table_id = aws_route_table.lab5-route-table.id
}

resource "aws_instance" "lab5-instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.lab5-sn1.id

  tags = {
    Name = "lab5"
  }

  key_name               = "TF_key"
  vpc_security_group_ids = [aws_security_group.lab5-sg.id]
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh

}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "TF_key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "TF_key"
  file_permission = "400"

}


output "public_ip" {
  value = aws_instance.lab5_instance.public_ip
}
