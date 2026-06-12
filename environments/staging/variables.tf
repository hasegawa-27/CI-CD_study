variable "key_name" {
  description = "SSHキーペア名"
  type        = string
}

variable "my_ip" {
  description = "SSH接続を許可するIPアドレス"
  type        = string
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

variable "alert_email" {
  description = "アラート通知先のメールアドレス"
  type        = string
}

variable "subnet_cidr_1c" {
  description = "Public subnet CIDR for AZ 1c"
  type        = string
  default     = "10.0.4.0/24"
}

variable "env" {
  description = "環境名"
  type        = string
  default     = "dev"
}
