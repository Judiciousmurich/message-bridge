# Change Ledger

Append-only record of agent work. Newest entries first. One entry per turn.
Business rules are tracked separately in
[`business-rules.md`](business-rules.md).

## 2026-11-04 10:48 — Establish per-turn ledger and commit protocol

- Intent: Make every agent turn traceable by requiring a change ledger entry, a
  business rules update when behavior changes, and a commit before the turn
  ends.
- Changed:
  - `AGENTS.md` (new) — mandatory turn protocol, ledger formats, verification,
    and commit rules.
  - `docs/change-ledger.md` (new) — this file.
  - `docs/business-rules.md` (new) — seeded BR-001 through BR-020 from
    `README.md`.
  - Git repository initialized on branch `main` with this baseline.
- Behavior: `none` (documentation and workflow only).
- Business rules: Initial baseline recorded (`BR-001`–`BR-020`); no existing
  behavior changed.
- Verification: `not run (docs only)`; commit dry-run inspected to confirm no
  local configuration or generated files are staged.
- Commit: `docs(agent): establish per-turn ledger and commit protocol`
