"""
Deliberately leaked credentials for the CI/CD secret-scanning demo (see
cicd-demo-app/README.md). All three of these are fake and unusable - not
the well-known AWS/Stripe documentation placeholder values (those are
allowlisted by most secret scanners, including this one, precisely because
they show up in so many public repos - using them here would silently
produce zero findings instead of demonstrating the detection).
"""

# Matches the AKIA[16 alphanumeric] AWS access key ID pattern.
AWS_ACCESS_KEY_ID = "AKIA2PLANEXDEMOKEY01"

# Matches AWS's 40-character secret access key format.
AWS_SECRET_ACCESS_KEY = "PLANEXdemoSECRETkey1234567890abcdefGHIJ"

# Matches Stripe's live secret key format (sk_live_...).
STRIPE_SECRET_KEY = "sk_live_51MxAmPL3PlanExFakeKeyDoNotUse00"

# A full connection string with embedded credentials - a different, very
# common real-world secret-leak shape (not a bare API key) than the two
# above.
DATABASE_URL = "postgresql://planex_app:SuperSecretDBPass!23@planex-prod-db.cluster-abc123.us-east-1.rds.amazonaws.com:5432/shipments"
