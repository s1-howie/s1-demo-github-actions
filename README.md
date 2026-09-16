# CI/CD Shift-Left Scanning Demo

Unlike every scenario in the `aws/`, `azure/`, and `gcp/` environments of
[s1-cnapp-terraform](https://github.com/s1-dillondoxey/s1-cnapp-terraform)
(which deploy real, intentionally vulnerable cloud infrastructure for
SentinelOne's runtime/CNAPP detection), this repo demonstrates **shift-left**
scanning instead: catching problems in code *before* it's ever deployed, via
the [SentinelOne CNS CLI](https://www.sentinelone.com) (`s1-shift-left-cli`)
running in a GitHub Actions pipeline (`.github/workflows/s1-cns-scan.yml`).

**⚠️ Nothing in this repo is ever built, deployed, or run for real.** The
app, its Dockerfile, and the Terraform snippet in `infra/` all exist purely
as committed source for the scanner to find things in.

This repo's entire content (including this README and the workflow file) is
provisioned by Terraform from `s1-cnapp-terraform`'s `github/` environment -
edit the source there and re-apply, rather than editing directly here, so
the two stay in sync.

---

## What's in here

| Path | Purpose |
|------|---------|
| `app/app.py`, `app/config.py` | A tiny fictional "PlanEx Shipping API" Flask app, with hardcoded fake AWS/Stripe credentials and a DB connection string in `config.py` - **secret scanning** target. |
| `app/requirements.txt` | Deliberately outdated Flask/Werkzeug/Jinja2/PyYAML/requests/urllib3 pins, each with real, well-documented CVEs - **vulnerability scanning** target (language dependencies). |
| `Dockerfile` | Built on `python:3.6` (long EOL) - **vulnerability scanning** target (OS packages), if you also want to demo `scan vuln --docker-image`. |
| `infra/main.tf` | A standalone Terraform snippet (never applied - no state, no backend) with a public/unencrypted S3 bucket, a wildcard-admin IAM policy, a security group open to `0.0.0.0/0` on every port, and a CloudWatch log group tagged with `s1-cns-skip` to demonstrate the exception mechanism - **IaC scanning** target. |

The fake credentials in `config.py` are deliberately **not** the famous
AWS/Stripe documentation placeholder values (`AKIAIOSFODNN7EXAMPLE` etc.) -
those are allowlisted by most secret scanners precisely because they show up
in so many public repos, which would silently produce zero findings here
instead of demonstrating detection.

---

## One-time setup (outside Terraform - do this in the SentinelOne console and GitHub)

1. **Create a CI/CD role and service user** in the Singularity™ Operations
   Center: *Policies and settings → User Management → Roles → New Role*,
   enable the **Publish CNS CLI Findings** and **Get CNS CLI Scan Rules**
   permissions, then create a service user with that role (*Account* or
   *Site* scope - **not** Global) and save its API token.
2. **Find your scope ID**: *Policies and settings → Scope information*.
3. **Create or identify a scanner policy** and note its policy ID (*Policies
   and settings → Cloud Security - Integrations → CI/CD* also lets you
   generate/inspect this).
4. **Set `s1_service_user_api_token`, `s1_management_console_url`,
   `s1_scope_type`, `s1_scope_id`, and `s1_policy_id`** in
   `s1-cnapp-terraform/github/environments/demo/terraform.tfvars` and
   re-apply - Terraform manages this repo's Actions secret/variables for you
   (see that environment's README/tfvars.example for details), so there's
   nothing to configure by hand in GitHub's own Settings UI.
5. **Enable GitHub Actions** for this repo if it isn't already (*Settings →
   Actions → General*) - Terraform can't flip this one for you (GitHub's API
   doesn't expose it).

The workflow file here is a hand-authored analog of the one the Singularity
console normally generates for you once you complete this flow through its
own UI (*Policies and settings → Cloud Security - Integrations → CI/CD →
GitHub Actions*) - that console flow injects a real policy ID into its own
template automatically. Consider swapping this file for the console-generated
one once you've been through that flow for real.

---

## Demoing it

**Important first-time gotcha**: GitHub only runs a `pull_request`-triggered
workflow if that workflow file already exists on the base branch (`main`) at
the time the PR opens - the very first `terraform apply` that creates this
repo (and commits the workflow file to its default branch directly) sidesteps
this, since the file lands on `main` immediately rather than arriving via a
PR. Just be aware that if you ever remove and re-add the workflow file via a
PR instead, that specific PR won't trigger itself.

Open a pull request that touches anything in this repo (even a trivial
change, like editing this README). Watch the **Checks** tab: three steps
(secret scan, IaC scan, vulnerability scan) run and publish results to the
Singularity™ Operations Center CI/CD dashboard, in addition to failing the
GitHub check if your configured scan policy's exit conditions are met.

To show the "fix it and the check goes green" arc: pin a
`requirements.txt` entry to a patched version, remove the public-access
block override in `infra/main.tf`, or delete a hardcoded credential from
`config.py`, then push again to the same PR.
