# Repository Guidelines

## Project Structure & Module Organization
- Root config: `cloud-init.yaml` — provisions packages and writes helper scripts via `write_files`, then runs them in order using `runcmd`.
- Generated scripts (on the VM): `/usr/local/bin/install_*.sh` — Ruby (rbenv), Terraform, Tailscale, Node/NVM and CLIs.
- Meta folders: `.git/` (history), `.claude/` (editor/AI settings). No app source code in this repo.

## Build, Test, and Development Commands
- Validate YAML: `yamllint cloud-init.yaml` — catch indentation/syntax issues.
- Quick diff check: `git diff --word-diff cloud-init.yaml` — verify minimal changes.
- Local VM test (Multipass): `multipass launch jammy --name ci-test --cloud-init cloud-init.yaml`
  - Verify on VM: `multipass exec ci-test -- bash -lc 'ruby -v; node -v; terraform version; systemctl is-active tailscaled'`
- Oracle Cloud: paste the full `cloud-init.yaml` into the “User data” field when creating the instance.

## Coding Style & Naming Conventions
- YAML: 2‑space indent, no tabs; group related keys; keep comments short and actionable.
- Shell (embedded in `write_files`): use `#!/usr/bin/env bash` and `set -euo pipefail`; prefer functions; quote variables; avoid sudo inside scripts (they run as root); name installers `install_<tool>.sh`.
- Commands: prefer idempotent operations; use `apt-get` with `-y`; check connectivity before remote fetches.

## Testing Guidelines
- Lint scripts: extract changed script blocks and run `shellcheck -s bash`.
- Dry run: launch an ephemeral VM (Multipass or cloud provider) and confirm tool versions and active services as above.
- Rollback safety: keep changes additive and reversible; avoid removing working installers without discussion.

## Commit & Pull Request Guidelines
- Commits: follow Conventional Commits (`feat:`, `fix:`, `chore:`) as seen in history.
- PRs must include: purpose, high‑level changes, risk/impact, manual test plan (commands/output), and any follow‑ups.
- Screenshots or logs: include `systemctl status tailscaled` and tool `--version` outputs for validation.
- Checklist: YAML lints clean, scripts pass `shellcheck`, VM test succeeds, no secrets embedded.

## Security & Configuration Tips
- Do not hardcode tokens; run `tailscale up` interactively post‑provision.
- Keep versions pinned where stability matters; prefer HTTPS and GPG‑verified repos.
