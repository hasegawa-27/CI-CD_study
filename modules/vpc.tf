resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a" # 例: ap-northeast-1a

  tags = {
    Name = "${var.env}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_1c
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "${var.env}-public-subnet-1c"
  }
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}