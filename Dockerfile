# Deliberately old base image (EOL, long unpatched) for the vulnerability-
# scanning demo - see cicd-demo-app/README.md. Never actually built/run
# anywhere; exists purely as a scan target for `s1-cns-cli scan vuln
# --docker-image` (OS-package CVEs) alongside the requirements.txt-based
# scan (language-package CVEs).
FROM python:3.6-slim

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]
