"""
Deliberately leaked credentials for the CI/CD secret-scanning demo (see
cicd-demo-app/README.md). All three of these are fake and unusable.
"""

# AWS Canary Token
AWS_ACCESS_KEY_ID = "AKIA3ZSAAYKVTW3NBM7L"

# AWS Canary Token.
AWS_SECRET_ACCESS_KEY = "P3gPx5kSXga/ZPb/IkmZAbTyjCspZ+3hnUyYl3wp"

# Matches Stripe's live secret key format (sk_test_...).
STRIPE_SECRET_KEY = "sk_test_51L53TeSBwzby5YcBooVe7xqrw9DrV7SWyW5WKKYGSFO4fNSoDyd167DZrmIW6lZE6pHUDrYe9zfqGnCHTQUKhnPc00eL5w5pxY"

# A full connection string with embedded credentials - a different, very
# common real-world secret-leak shape (not a bare API key) than the two
# above.
DATABASE_URL = "postgresql://planex_app:SuperSecretDBPass!23@planex-prod-db.cluster-abc123.us-east-1.rds.amazonaws.com:5432/shipments"
