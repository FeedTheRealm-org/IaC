# External Commands

This document contains all the external commands that where ran utilizing the AWS cli or other.

⚠️ Keep this up-to-date always **(these cannot be destroyed or modified by terraform)**!

## Terraform state s3 bucket

```bash
# Create bucket
aws s3api create-bucket --bucket feedtherealm-terraform-state --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2 --profile iamadmin

# Server encryption
aws s3api put-bucket-encryption --bucket feedtherealm-terraform-state --server-side-encryption-configuration '{\
    "Rules": [{\
    "ApplyServerSideEncryptionByDefault": {\
        "SSEAlgorithm": "AES256"\
      }\
    }]\
  }' --profile iamadmin
```
