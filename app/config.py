"""
Deliberately leaked credentials for the CI/CD secret-scanning demo. 

All three of these are fake and unusable.
"""

# AWS Canary Token
AWS_ACCESS_KEY_ID = "AKIA3ZSAAYKVTW3NBM7L"

# AWS Canary Token
AWS_SECRET_ACCESS_KEY = "P3gPx5kSXga/ZPb/IkmZAbTyjCspZ+3hnUyYl3wp"

# Matches Stripe's test secret key format (sk_test_...).
STRIPE_SECRET_KEY = "sk_test_51RISgKRc7i2tZ94OMKyqkkCcDHuXmIwR8lbTieHmk5tblj6Jow02UPG3tODwVuEog4XR6DNbEDlsLQjsN694gjcp00mAjkeuLU"

# A full connection string with embedded credentials - A very common
# real-world secret-leak shape (not a bare API key) like the two above.
DATABASE_URL = "postgresql://planex_app:SuperSecretDBPass!23@planex-prod-db.cluster-abc123.us-east-1.rds.amazonaws.com:5432/shipments"
