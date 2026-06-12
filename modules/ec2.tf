resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_cloudwatch.name

  tags = {
    Name = "${var.env}-ec2"
  }
}

resource "aws_instance" "sub" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_1c.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_cloudwatch.name

  tags = {
    Name = "${var.env}-ec2-sub" # 既存と名前が被らないように -sub をつける
  }
}