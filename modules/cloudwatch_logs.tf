resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/${var.env}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.env}-ec2-log-group"
  }
}

resource "aws_cloudwatch_log_group" "rds" {
  name              = "/aws/rds/${var.env}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.env}-rds-log-group"
  }
}

resource "aws_cloudwatch_log_group" "alb" {
  name              = "/aws/alb/${var.env}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.env}-alb-log-group"
  }
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.env}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.env}-waf-log-group"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

resource "aws_iam_role" "ec2_cloudwatch" {
  name = "${var.env}-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.env}-ec2-cloudwatch-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cloudwatch" {
  name = "${var.env}-ec2-instance-profile"
  role = aws_iam_role.ec2_cloudwatch.name
}