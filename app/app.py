"""
PlanEx Shipping API - a deliberately unremarkable little Flask service.

This app has no purpose other than being scanned by SentinelOne CNS CLI's
shift-left tooling (secret + vulnerability scanning - see README.md). It is
never deployed anywhere; it exists purely as committed source for
`s1-cns-cli scan secret` / `scan vuln` to find things in.
"""

from flask import Flask, jsonify

from config import DATABASE_URL, STRIPE_SECRET_KEY

app = Flask(__name__)


@app.route("/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/track/<shipment_id>")
def track(shipment_id):
    # Not a real query - just references the "leaked" DB credential above so
    # it isn't flagged as unused dead code by anything skimming this file.
    return jsonify({"shipment_id": shipment_id, "status": "in_transit", "db": DATABASE_URL})


@app.route("/billing/charge")
def charge():
    # Same idea - references the "leaked" Stripe key above.
    return jsonify({"charged": True, "using_key_prefix": STRIPE_SECRET_KEY[:12]})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
