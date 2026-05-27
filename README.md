# CI-CD_study

## インフラ構成概要
TerraformによるAWSインフラのCI/CD自動化

## 必須対応3点の確認

### ① Environment Protection
GitHub Settings → Environments → productionにて
Required reviewersを設定済み（承認必須）
ワークフローの`environment: production`と一致

### ② S3・DynamoDB・IAMロールの確認
- S3バケット: ci-cd-study.tfstate-bucket-812063706542-ap-northeast-1-an（作成済み）
- DynamoDBテーブル: ci_cd_study.tfstate（作成済み）
- IAMロール: CI-CD-study-role
  - 信頼ポリシー: GitHub OIDCを許可
  - 許可ポリシー: s3:* / dynamodb:* / ec2:* / iam:*等を付与済み

### ③ ALB・SG・TGの確認
- ALB: internal = false（internet-facing）
- ALB SG: HTTP(80)・HTTPS(443)のみ許可（SSH22番なし）
- EC2 SG: SSH(22)はvar.my_ip/32で自分のIPのみに限定
- TGポート: 80番で統一（テストと実運用で一致）
