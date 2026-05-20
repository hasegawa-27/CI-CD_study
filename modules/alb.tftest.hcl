variables {
  subnet_cidr_1c = "10.0.4.0/24"
}

run "ALBのテスト" {
  command = apply

  assert {
    condition     = aws_lb.main.internal == false
    error_message = "ALBが内部向けになっています（外部公開されていません）"
  }

  assert {
    condition     = aws_lb.main.load_balancer_type == "application"
    error_message = "ロードバランサーのタイプが違います"
  }

  assert {
    condition     = aws_lb.main.tags["Name"] == "${var.env}-alb"
    error_message = "ALBのタグ名が違います"
  }
}

run "ターゲットグループのテスト" {
  command = apply

  assert {
    condition     = aws_lb_target_group.main.port == 80
    error_message = "ターゲットグループのポートが違います"
  }

  assert {
    condition     = aws_lb_target_group.main.protocol == "HTTP"
    error_message = "ターゲットグループのプロトコルが違います"
  }

  assert {
    condition     = aws_lb_target_group.main.tags["Name"] == "${var.env}-tg"
    error_message = "ターゲットグループのタグ名が違います"
  }
}

run "ALBリスナーのテスト" {
  command = apply

  assert {
    condition     = aws_lb_listener.http.port == 80
    error_message = "リスナーのポートが違います"
  }

  assert {
    condition     = aws_lb_listener.http.protocol == "HTTP"
    error_message = "リスナーのプロトコルが違います"
  }
}

run "ターゲットグループアタッチメントのテスト" {
  command = apply

  assert {
    condition     = aws_lb_target_group_attachment.main.port == 80
    error_message = "アタッチメントのポートが違います"
  }

  assert {
    condition     = aws_lb_target_group_attachment.main.target_id == aws_instance.main.id
    error_message = "EC2インスタンスが正しく紐付いていません"
  }

  # ↓ 追記
  assert {
    condition     = aws_lb_target_group_attachment.sub.port == 80
    error_message = "サブEC2のアタッチメントのポートが違います"
  }

  assert {
    condition     = aws_lb_target_group_attachment.sub.target_id == aws_instance.sub.id
    error_message = "サブEC2インスタンスが正しく紐付いていません"
  }
}