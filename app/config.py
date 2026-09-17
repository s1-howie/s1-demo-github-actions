"""
Deliberately leaked credentials for the CI/CD secret-scanning demo (see
cicd-demo-app/README.md). All three of these are fake and unusable - not
the well-known AWS/Stripe documentation placeholder values (those are
allowlisted by most secret scanners, including this one, precisely because
they show up in so many public repos - using them here would silently
produce zero findings instead of demonstrating the detection).
"""

# AWS Canary Token
AWS_ACCESS_KEY_ID = "AKIA3ZSAAYKVTW3NBM7L"

# AWS Canary Token.
AWS_SECRET_ACCESS_KEY = "P3gPx5kSXga/ZPb/IkmZAbTyjCspZ+3hnUyYl3wp"

# Matches Stripe's live secret key format (sk_test_...).
STRIPE_SECRET_KEY = "sk_test_51RISgKRc7i2tZ94OMKyqkkCcDHuXmIwR8lbTieHmk5tblj6Jow02UPG3tODwVuEog4XR6DNbEDlsLQjsN694gjcp00mAjkeuLU"

# A full connection string with embedded credentials - a different, very
# common real-world secret-leak shape (not a bare API key) than the two
# above.
DATABASE_URL = "postgresql://planex_app:SuperSecretDBPass!23@planex-prod-db.cluster-abc123.us-east-1.rds.amazonaws.com:5432/shipments"
