# Change Ledger

Append-only record of agent work. Newest entries first. One entry per turn.
Business rules are tracked separately in
[`business-rules.md`](business-rules.md).

## 2026-11-04 10:55 — Check Android run prerequisites

- Intent: Determine how to run the app on the user's Android device.
- Changed: `docs/change-ledger.md` (this entry only).
- Findings:
  - Flutter 3.22.3 is installed and working.
  - Android SDK, JDK, and Android Studio are not installed.
  - `Xcode.app` (4.7 GB) exists in `~/Downloads` but is not selected;
    `xcode-select` points to the Command Line Tools. Xcode cannot build
    Android targets.
  - No Android phone is visible over USB and no emulator is configured.
  - Free disk space is 1.6 GiB, which is not enough for the Android SDK,
    Gradle downloads, and build output.
  - The OpenJDK 17 installation was started and then cancelled.
- Behavior: `none` (environment audit only).
- Business rules: `none`.
- Verification: `flutter doctor -v`, `flutter devices`, `xcodebuild -version`,
  `xcrun simctl`, and a USB device probe were run and read.
- Commit: `docs(agent): record Android run readiness check`

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
