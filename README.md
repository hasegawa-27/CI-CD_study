# CI-CD_study

## インフラ構成概要
TerraformによるAWSインフラのCI/CD自動化

## 必須対応3点の確認

### 1 Environment Protection
GitHub Settings → Environments → productionにて
Required reviewersを設定済み(承認必須)
ワークフローの`environment: production`と一致

### 2 S3・DynamoDB・IAMロールの確認
- S3バケット: ci-cd-study.tfstate-bucket-AWSアカウントID-ap-northeast-1-an(作成済み)
  - パブリックアクセスブロック: 全て有効 / 暗号化: 有効 / バージョニング: 有効
  - バケットポリシー: HTTPS以外を拒否、アカウント外からのアクセスを拒否
- DynamoDBテーブル: ci_cd_study.tfstate(作成済み)
  - 公開エンドポイントなし。アクセスはIAMのみで制御
- IAMロール: CI-CD-study-role
  - 信頼ポリシー: GitHub OIDCを許可(対象リポジトリの main / feature/* / PR のみ)
  - 許可ポリシー: 最小権限に限定(iam:* は不使用)
    - S3(ステート): ListBucket / GetObject / PutObject / DeleteObject(対象バケットのみ)
    - DynamoDB(ロック): GetItem / PutItem / DeleteItem(対象テーブルのみ)
    - インフラ作成: ec2 / rds / elasticloadbalancing / cloudwatch / logs / wafv2 / sns
    - IAM: EC2用ロール・インスタンスプロファイルの作成/付与のみ(PassRoleはEC2宛のみ)
  - ポリシー全文: github-oidc-role-policy.json

### 3 ALB・SG・TGの確認
- ALB: internal = false(internet-facing)
- ALB SG: HTTP(80)・HTTPS(443)のみ許可(SSH22番なし)
- EC2 SG: SSH(22)はvar.my_ip/32で自分のIPのみに限定
- TGポート: 80番で統一(テストと実運用で一致)
