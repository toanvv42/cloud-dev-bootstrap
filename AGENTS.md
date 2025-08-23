# Repository Guidelines

## Project Structure & Module Organization
- Root contains all assets for bootstrapping a dev machine:
  - `cloud-init.yaml`: Cloud-Init user-data to provision a fresh VM.
  - `install_rbenv.sh`: Installs rbenv and Ruby toolchain.
  - `install_terraform_wireguard.sh`: Installs Terraform and WireGuard tooling.
- Keep new provisioning scripts in the repository root (or create `scripts/` if volume grows). Name files with lowercase snake_case.

## Build, Test, and Development Commands
- Validate Cloud‑Init: `cloud-init schema --config-file cloud-init.yaml` (checks syntax/schema).
- Try Cloud‑Init locally: `multipass launch --cloud-init cloud-init.yaml` (spins a test VM).
- Run scripts directly:
  - `bash install_rbenv.sh`
  - `bash install_terraform_wireguard.sh`
- Lint and format:
  - `shellcheck *.sh` (static analysis for Bash)
  - `shfmt -w *.sh` (format Bash)
  - `yamllint cloud-init.yaml` (validate YAML style)

## Coding Style & Naming Conventions
- Bash: `#!/usr/bin/env bash` at top, `set -euo pipefail`, 2‑space indentation, functions over inline blocks, constants in UPPER_SNAKE_CASE, variables in lower_snake_case.
- YAML: 2‑space indentation, hyphenated keys where idiomatic to Cloud‑Init, keep logical section order (users, packages, write_files, runcmd).
- Filenames: lowercase snake_case; scripts must be executable (`chmod +x`).

## Testing Guidelines
- Static checks: run `shellcheck` and `yamllint` on every change.
- Safety: scripts should be idempotent and re‑runnable; guard with existence checks (e.g., `command -v terraform >/dev/null || ...`).
- Functional test: provision a disposable VM with the Cloud‑Init file and verify expected packages, users, and services.

## Commit & Pull Request Guidelines
- Commits: use Conventional Commits (e.g., `feat: add wireguard install step`, `fix: pin terraform version`).
- PRs must include: concise description, rationale, test notes (commands run, outputs), and any security implications. Link related issues.
- Screenshots or logs: include `cloud-init status --long` or script output snippets when relevant.

## Security & Configuration Tips
- Never commit secrets or private keys. Use environment variables or separate, ignored files (e.g., `.env.local`).
- Prefer pinned versions and checksums for downloads. Require `sudo` only when necessary and verify `EUID` before privileged actions.
