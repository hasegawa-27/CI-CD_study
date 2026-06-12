resource "aws_sns_topic" "alert" {
  name = "${var.env}-alert-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alert.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.env}-ec2-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2のCPU使用率が80%を超えました"

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  alarm_actions = [aws_sns_topic.alert.arn]
  ok_actions    = [aws_sns_topic.alert.arn]

  tags = {
    Name = "${var.env}-ec2-cpu-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.env}-rds-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDSのCPU使用率が80%を超えました"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = [aws_sns_topic.alert.arn]
  ok_actions    = [aws_sns_topic.alert.arn]

  tags = {
    Name = "${var.env}-rds-cpu-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.env}-alb-5xx-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALBで5xxエラーが増加しています"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alert.arn]
  ok_actions    = [aws_sns_topic.alert.arn]

  tags = {
    Name = "${var.env}-alb-5xx-alarm"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ec2_error" {
  name           = "${var.env}-ec2-error-filter"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.ec2.name

  metric_transformation {
    name      = "EC2ErrorCount"
    namespace = "${var.env}/EC2Logs"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_error" {
  alarm_name          = "${var.env}-ec2-error-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EC2ErrorCount"
  namespace           = "${var.env}/EC2Logs"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "EC2のログにERRORが増加しています"

  alarm_actions = [aws_sns_topic.alert.arn]

  tags = {
    Name = "${var.env}-ec2-error-alarm"
  }
}