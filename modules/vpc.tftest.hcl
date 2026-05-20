variables {
  subnet_cidr_1c = "10.0.4.0/24"
}

run "VPCのテスト" {
  command = apply

  assert {
    condition     = aws_vpc.main.cidr_block == var.vpc_cidr
    error_message = "VPCのCIDRブロックが違います"
  }

  assert {
    condition     = aws_vpc.main.tags["Name"] == "${var.env}-vpc"
    error_message = "VPCのタグ名が違います"
  }
}

run "インターネットゲートウェイのテスト" {
  command = apply

  assert {
    condition     = aws_internet_gateway.main.vpc_id == aws_vpc.main.id
    error_message = "IGWがVPCに紐付いていません"
  }

  assert {
    condition     = aws_internet_gateway.main.tags["Name"] == "${var.env}-igw"
    error_message = "IGWのタグ名が違います"
  }
}

run "パブリックサブネットのテスト" {
  command = apply

  assert {
    condition     = aws_subnet.public.cidr_block == var.subnet_cidr
    error_message = "サブネットのCIDRブロックが違います"
  }

  assert {
    condition     = aws_subnet.public.availability_zone == "${var.aws_region}a"
    error_message = "アベイラビリティゾーンが違います"
  }

  assert {
    condition     = aws_subnet.public_1c.availability_zone == "${var.aws_region}c"
    error_message = "1cサブネットのAZが違います"
  }
}

run "ルートテーブルのテスト" {
  command = apply

  assert {
    condition     = aws_route_table_association.public.subnet_id == aws_subnet.public.id
    error_message = "ルートテーブルがサブネットに紐付いていません"
  }
}