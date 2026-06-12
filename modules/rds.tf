resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.env}-private-subnet-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "${var.env}-private-subnet-1c"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "${var.env}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name = "${var.env}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${var.env}-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.env}-rds"
  }
}