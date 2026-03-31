# Kolide Community Checks

A community-maintained collection of checks and rules for the [Kolide](https://www.kolide.com/) platform.

## What is this?

This repository contains community-contributed checks, queries and rules that run on endpoints via Kolide, to help teams monitor device health, security posture, and compliance.

## Philosophy

- **Checks are primarily for user-driven configurations and changes.** They can verify that MDM-applied device policies have taken effect, but be aware that this adds latency at authentication checkpointsm, conflating MDM enforcement with user-actionable checks creates a poor user experience. Choose checks wisely.
- **Checks should be user actionable.** If a user cannot reasonably fix the issue themselves, reconsider whether a check is the right tool.
- **Checks are for compliance, not education.** They surface policy violations; they do not replace communicating expectations to users.

## Check Directory Structure

```
checks/
  <check-name>/
    check.sql        # osquery SQL query
    metadata.yaml    # check metadata (name, descriptions, platforms, author, tags, etc.)
```

Checks are not split by platform - a single check can declare support for one or more platforms via `metadata.yaml`. This reflects how Kolide works: many queries run identically on macOS, Windows, and Linux.

> See [checks/example-check/metadata.yaml](checks/example-check/metadata.yaml) for a fully annotated example.


---

## Contributing

Please read this guide before submitting a check.

### Licensing

- Only submit checks you wrote yourself or have explicit permission to share.
- Do not submit checks authored by Kolide, 1Password, or any other third party unless the license explicitly permits redistribution.

### Check Naming

Name checks after the **desired state** (what should be true on a healthy device) in lowercase kebab-case.

- `filevault-enabled` ✓
- `firewall-enabled` ✓
- `gatekeeper-enabled` ✓
- `screensaver-password-required` ✓
- `ssh-root-login-disabled` ✓

**Rules:**
- No `check-` prefix or `-check` / `-rule` suffix - everything here is a check
- No platform in the name - declare it in `metadata.yaml`
    - Unless the check is truly platform-specific and would be confusing otherwise (e.g. `windows-defender-enabled`), but prefer platform-agnostic names when possible
- Spell out words unless the abbreviation is universally known (`ssh`, `tpm`, `usb` are fine; `fw` for firewall is not where it may be confused with firmware)

### Adding a Check

1. **Fork** this repository and create a feature branch.
2. **Create a subdirectory** under `checks/` for your check (use `kebab-case`):
   ```
   checks/my-new-check/
   ```
3. **Add the required files** (see structure below).
4. **Declare platform support** in `metadata.yaml` - a check can target one platform or several.
5. **Open a pull request** against `main`.

### Check Structure

Each check directory must contain:

```
checks/<check-name>/
  check.sql        # The osquery SQL query
  metadata.yaml    # Check metadata (see below)
```

#### metadata.yaml

```yaml
name: Human-readable check name        # Describes the "Passing" state
issue_title: Short issue title         # Describes the "Failing" state
description: One-sentence description. # Visible to Kolide admins in the check catalog; supports markdown
rationale: |                           # Supports markdown
  Why failing this check is a problem.
fix_instructions: |                    # Supports markdown
  Steps an inexperienced user could follow to fix this.
additional_privacy_concerns: |         # Optional; supports markdown; visible to end-users in the Privacy Center
  What private details this check might disclose.
icon: https://example.com/icon.png     # Optional; URL to an image shown on the Kolide check
platforms:
  - macos          # macos | windows | linux
author: your-github-username
tags:
  - security       # e.g. security, compliance, inventory, performance
```

#### check.sql

A valid osquery SQL query. Keep it focused, one concern per check.

```sql
SELECT
  name,
  version,
  ...
FROM some_osquery_table
WHERE condition = 'value';
```

**Constraints:**
- Checks must be self-contained - no supplemental scripts or external files.
    - Referencing files that ship with the operating system is fine (e.g. `/etc/someconfig.conf`), but do not reference files that may not exist on all endpoints (e.g. a script in the user’s home directory).
- Avoid dubious osquery tables. Kolide flags these as unreliable or potentially unsafe. The following tables are considered dubious: `asl`, `carves`, `dns_cache`, `running_apps`, `example`, `kolide_app_icons`, `kolide_program_icons`, `kolide_airport_util`, `kolide_wifi_networks`, `kolide_nmcli_wifi`, `windows_eventlog`, `shell_history`, `process_envs`, `quicklook_cache`, `curl`, `curl_certificate`. 

If you must use one, declare it explicitly in `metadata.yaml`:
```yaml
dubious_tables:
  - curl
```

CI will fail if a dubious table is used without this declaration. It will warn (but not fail) when one is declared, so reviewers are aware.

### Pull Request Checklist

All items must be checked before a PR will be accepted for peer review. The `Verify checklist is complete` CI job enforces this automatically.

- [ ] I have created a `checks/<check-name>/` directory, with platforms configured in `metadata.yaml`.
- [ ] I have verified that `metadata.yaml` includes all required fields.
- [ ] I have verified that `check.sql` is a valid osquery query.
- [ ] I have permission to share this check publicly.
- [ ] I have personally tested this check and verified it produces the expected results.

You will also be asked to disclose whether any AI/LLM tooling was used to assist with the contribution. This is not a disqualifier - it helps reviewers apply appropriate scrutiny.

### CI

Pull requests are automatically linted across three jobs:

| Job | What it checks |
|-----|---------------|
| **structure** | Naming convention, required files present, no extra files, no dubious osquery tables |
| **yaml** | `metadata.yaml` is valid YAML with correct fields |
| **sql** | `check.sql` passes sqlfluff (SQLite dialect) |

Fix any CI failures before requesting review.

## Issues

Found a problem with an existing check? [Open an issue](../../issues).

## License

[MIT](LICENSE)
