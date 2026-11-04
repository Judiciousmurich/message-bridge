# Change Ledger

Append-only record of agent work. Newest entries first. One entry per turn.
Business rules are tracked separately in
[`business-rules.md`](business-rules.md).

## 2026-11-04 11:05 — Assess iPhone distribution options

- Intent: Explain how to share the iOS app with another iPhone user.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The only signing identity is `Apple Development`, and the embedded profile
    is an iOS Team Provisioning Profile that expires on 2026-11-10 — seven days
    after it was created — and lists only the current iPhone.
  - This is free personal-team signing: development builds are device-bound and
    expire after seven days. Ad Hoc and TestFlight require the paid Apple
    Developer Program.
  - The iOS UI is the manual WhatsApp compose flow and stores no Twilio
    credentials, so sharing it does not expose account secrets.
  - Automatic SMS forwarding remains Android-only.
- Behavior: `none`.
- Business rules: `none`.
- Verification: checked signing identities, the embedded
  `mobileprovision`, profile expiry/device list, and the Xcode signing settings.
- Commit: `docs(agent): assess iPhone distribution options`



- Intent: Get the app running on the connected iPhone 13 Pro Max ("Judicious")
  after Xcode stopped at launch with `SIGABRT`.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - Xcode 26.3 is installed at `~/Downloads/Xcode.app` and was used directly;
    `xcode-select` still points at the Command Line Tools.
  - The Flutter SDK is 3.22.3 (Dart 3.4.4) and the iPhone runs iOS 26.5.
  - The Debug build aborts during Dart VM startup with
    `mprotect failed: 13 (Permission denied)`. The device crash report confirms
    `SIGABRT` / `abort() called`.
  - Debug uses the Dart JIT, which iOS 26 no longer permits here. The Release
    build uses AOT and does not hit this path.
  - Installed `build/ios/Release-iphoneos/Runner.app` on the phone and launched
    `com.actserv.messageBridge`; the process stayed alive and no new crash
    report was written.
- Behavior: `none` (the app is now running in Release; automatic SMS forwarding
  remains Android-only, iOS uses the manual compose flow).
- Business rules: `none`.
- Verification: copied and parsed the device crash report; extracted the Xcode
  console log; installed and launched with `devicectl`; confirmed the Runner
  process was still alive 12 seconds later and that no new crash log appeared.
- Commit: `docs(agent): record iOS release-mode run workaround`



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
