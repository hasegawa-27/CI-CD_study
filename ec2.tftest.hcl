variables {
  subnet_cidr_1c = "10.0.4.0/24"
}

run "EC2のテスト" {
  command = apply

  assert {
    condition     = aws_instance.main.instance_type == var.instance_type
    error_message = "インスタンスタイプが違います"
  }

  assert {
    condition     = aws_instance.main.associate_public_ip_address == true
    error_message = "パブリックIPが有効になっていません"
  }

  assert {
    condition     = aws_instance.main.subnet_id == aws_subnet.public.id
    error_message = "サブネットが正しく紐付いていません"
  }

  assert {
    condition     = aws_instance.main.tags["Name"] == "${var.env}-ec2"
    error_message = "EC2のタグ名が違います"
  }
}