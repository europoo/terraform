resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "ec2 security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "rds security group"
}

resource "aws_security_group_rule" "ec2_to_rds" {
  security_group_id        = aws_security_group.ec2_sg.id
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "rds_to_ec2" {
  security_group_id        = aws_security_group.rds_sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_instance" "rds_exercise" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = "TF_key"
  user_data_replace_on_change = true
  user_data                   =<<-EOF
        #!/bin/bash
        sudo apt-get update
        sudo apt-get install mysql-client -y
        EOF
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "my-subnet-group"
  subnet_ids = ["<subnet_ids>"]
}

resource "aws_db_instance" "db_instance" {
  engine                 = "mysql"
  instance_class         = "db.t2.micro"
  username               = ""
  password               = ""
  allocated_storage      = "20"
  storage_type           = "gp2"
  publicly_accessible  = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
}

output "ec2_public_ip_for_mysql" {
  value = aws_instance.rds_exercise.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}
