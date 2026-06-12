# Terraform State 管理とセキュリティ設定

本ドキュメントは、本リポジトリにおける tfstate の管理方式、GitHub Actions(OIDC)用 IAM ロールの許可ポリシー、および tfstate 保管用 S3 バケットの保護設定をまとめた証跡資料である。

## 1. tfstate の保管構成

tfstate は S3 リモートバックエンドで管理し、環境ごとにキー(保存パス)を分離している。

| 項目 | 設定 |
|---|---|
| バケット | `ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an` |
| prod 用キー | `prod/terraform.tfstate` |
| staging 用キー | `staging/terraform.tfstate` |
| リージョン | `ap-northeast-1` |

## 2. ロック方式: S3 ネイティブロック(DynamoDB 不使用)

本構成では、従来の DynamoDB テーブルによるステートロックは使用せず、Terraform 1.10 以降で利用可能な **S3 ネイティブロック(`use_lockfile = true`)** を採用している。HashiCorp 公式が DynamoDB ロックを非推奨としたことを受けた対応である。

- 本リポジトリは `required_version = "1.14.8"` で固定しており、S3 ネイティブロックのバージョン要件(>= 1.10)を満たす
- 移行に伴い、ロック用 DynamoDB テーブルおよび IAM ポリシー内の DynamoDB 関連権限(`dynamodb:GetItem` / `PutItem` / `DeleteItem`)は削除済み
- ロック時はステートファイルと同一パスに `.tflock` ファイルが一時作成されるため、追加の IAM 権限は不要(既存の S3 オブジェクト操作権限でカバーされる)

backend 設定スニペット(environments/prod, environments/staging で同構成・キーのみ相違):

```hcl
terraform {
  required_version = "1.14.8" # use_lockfile は Terraform 1.10 以降が必要

  backend "s3" {
    bucket       = "ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an"
    key          = "prod/terraform.tfstate" # staging は staging/terraform.tfstate
    region       = "ap-northeast-1"
    use_lockfile = true # S3 ネイティブロック(DynamoDB 不使用)
  }
}
```

## 3. GitHub OIDC 用 IAM ロールの許可ポリシー

GitHub Actions からの AWS 認証には静的クレデンシャルを使用せず、OIDC によるロール引き受け(AssumeRoleWithWebIdentity)を採用している。ロールに付与している許可ポリシーは以下の通り。

### 設計方針

- **tfstate バケット操作**: バケット ARN・オブジェクト ARN を明記し、必要なアクション(`ListBucket` / `GetObject` / `PutObject` / `DeleteObject`)のみ許可
- **IAM 操作**: ロール・インスタンスプロファイルの ARN に限定。特に `iam:PassRole` は権限昇格の起点となり得るため、`iam:PassedToService: ec2.amazonaws.com` 条件で EC2 への引き渡しのみに制限
- **インフラプロビジョニング権限**(EC2 / RDS / ELB / CloudWatch / WAFv2 / SNS): EC2 系アクションの多くはリソースレベルのアクセス制御に非対応であり、また Terraform が新規作成するリソースの ARN は事前に特定できないため、サービス単位の許可とした。代わりに `aws:RequestedRegion: ap-northeast-1` 条件を付与し、東京リージョン外での操作を遮断することで影響範囲を限定している

### ポリシー JSON

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformStateBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an"
        },
        {
            "Sid": "TerraformStateObject",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an/*"
        },
        {
            "Sid": "ProvisionInfra",
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "rds:*",
                "elasticloadbalancing:*",
                "cloudwatch:*",
                "logs:*",
                "wafv2:*",
                "sns:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "ap-northeast-1"
                }
            }
        },
        {
            "Sid": "ProvisionEc2CloudWatchRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:UpdateRole",
                "iam:UpdateAssumeRolePolicy",
                "iam:TagRole",
                "iam:UntagRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:TagInstanceProfile"
            ],
            "Resource": [
                "arn:aws:iam::AWS_ID:role/*",
                "arn:aws:iam::AWS_ID:instance-profile/*"
            ]
        },
        {
            "Sid": "PassEc2CloudWatchRole",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::AWS_ID:role/*"
            ],
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "ec2.amazonaws.com"
                }
            }
        }
    ]
}
```

## 4. tfstate 用 S3 バケットの保護設定

tfstate には機密情報が含まれ得るため、バケット側で以下の多層的な保護を適用している。

### 4-1. ブロックパブリックアクセス

バケット設定で **「パブリックアクセスをすべてブロック」を有効化**(4 項目すべてオン)。バケットポリシーや ACL の設定ミスがあってもパブリック公開されない。

### 4-2. オブジェクト所有者(ACL 無効化)

「バケット所有者の強制」を適用し、ACL を無効化。アクセス制御をバケットポリシーと IAM に一元化している。

### 4-3. バケットポリシー

許可は IAM ポリシー側で付与し、バケットポリシーは **明示的 Deny によるガードレール** として使用している。

- `DenyInsecureTransport`: HTTPS 以外(非暗号化通信)でのアクセスを全拒否
- `DenyAccessOutsideAccount`: 自アカウント(AWS_ID)以外のプリンシパルからのアクセスを全拒否

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyInsecureTransport",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an",
                "arn:aws:s3:::ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
            "Sid": "DenyAccessOutsideAccount",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an",
                "arn:aws:s3:::ci-cd-study.tfstate-bucket-AWS_ID-ap-northeast-1-an/*"
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:PrincipalAccount": "AWS_ID"
                }
            }
        }
    ]
}
```

## 5. まとめ

| レイヤー | 対策 |
|---|---|
| 認証 | OIDC によるロール引き受け(静的クレデンシャル不使用) |
| IAM 許可 | tfstate・IAM 操作は ARN 明記、プロビジョニング権限はリージョン条件で制限、PassRole はサービス条件で制限 |
| ステートロック | S3 ネイティブロック(`use_lockfile`、Terraform >= 1.10) |
| バケット保護 | パブリックアクセス全ブロック + ACL 無効化 + 明示的 Deny(HTTPS 強制・他アカウント遮断) |

「ARN で絞り込める権限は最大限絞り、技術的に絞り込めない権限は条件(Condition)や別レイヤーの制御で補完する」という多層防御の方針で構成している。