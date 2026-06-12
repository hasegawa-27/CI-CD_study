variable "aws_region" {
  description = "使用するAWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}
variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "サブネットのCIDRブロック"
  type        = string
  default     = "10.0.1.0/24"
}

variable "env" {
  description = "環境名"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "EC2のAMI ID（Amazon Linux 2023）"
  type        = string
  default     = "ami-0599b6e53ca798bb2"
}

variable "instance_type" {
  description = "EC2インスタンスタイプ"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSHキーペア名"
  type        = string
}

variable "my_ip" {
  description = "SSH接続を許可するIPアドレス"
  type        = string
  validation {
    condition     = can(cidrhost("${var.my_ip}/32", 0))
    error_message = "my_ipは正しいIPv4アドレス形式で入力してください"
  }
}

variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "データベースのユーザー名"
  type        = string
}

variable "db_password" {
  description = "データベースのパスワード"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDSインスタンスタイプ"
  type        = string
  default     = "db.t3.micro"
}

variable "health_check_path" {
  description = "ヘルスチェックのパス"
  type        = string
  default     = "/"
}

variable "alert_email" {
  description = "アラート通知先のメールアドレス"
  type        = string
}

variable "waf_block_threshold" {
  description = "WAFのレートリミットの閾値（5分間のリクエスト)"
  type        = number
  default     = 2000 # 5分間で2000リクエストを超えたらブロック
}

variable "log_retention_days" {
  description = "ログの保持期間（日数）"
  type        = number
  default     = 30
}

variable "subnet_cidr_1c" {
  description = "Public subnet CIDR for AZ 1c"
  type        = string
}
