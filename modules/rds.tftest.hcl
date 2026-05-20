variables {
  subnet_cidr_1c = "10.0.4.0/24"
}

run "プライベートサブネットのテスト" {
  command = apply

  assert {
    condition     = aws_subnet.private_1a.cidr_block == "10.0.2.0/24"
    error_message = "1aサブネットのCIDRブロックが違います"
  }

  assert {
    condition     = aws_subnet.private_1a.availability_zone == "${var.aws_region}a"
    error_message = "1aサブネットのAZが違います"
  }

  assert {
    condition     = aws_subnet.private_1c.cidr_block == "10.0.3.0/24"
    error_message = "1cサブネットのCIDRブロックが違います"
  }

  assert {
    condition     = aws_subnet.private_1c.availability_zone == "${var.aws_region}c"
    error_message = "1cサブネットのAZが違います"
  }
}

run "DBサブネットグループのテスト" {
  command = apply

  assert {
    condition     = aws_db_subnet_group.main.name == "${var.env}-db-subnet-group"
    error_message = "DBサブネットグループ名が違います"
  }
}

run "RDSのテスト" {
  command = apply

  assert {
    condition     = aws_db_instance.main.engine == "mysql"
    error_message = "DBエンジンが違います"
  }

  assert {
    condition     = aws_db_instance.main.engine_version == "8.0"
    error_message = "DBエンジンのバージョンが違います"
  }

  assert {
    condition     = aws_db_instance.main.allocated_storage == 20
    error_message = "ストレージサイズが違います"
  }

  assert {
    condition     = aws_db_instance.main.publicly_accessible == false
    error_message = "RDSが公開されています（セキュリティ上問題があります）"
  }

  assert {
    condition     = aws_db_instance.main.tags["Name"] == "${var.env}-rds"
    error_message = "RDSのタグ名が違います"
  }
}