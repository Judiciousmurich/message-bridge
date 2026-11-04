# Change Ledger

Append-only record of agent work. Newest entries first. One entry per turn.
Business rules are tracked separately in
[`business-rules.md`](business-rules.md).

## 2026-11-04 11:55 — Install and launch Android app on itel A667L

- Intent: Complete the Android test by installing the built app on the connected
  phone.
- Changed:
  - No tracked source changes.
  - Installed the debug APK, then built and installed a 13.2 MB arm Release APK
    over it because the debug launch triggered repeated ANRs.
- Findings:
  - The debug ANR stack was
    `com.transsion.hubcore...TranActivityImpl.onResumeHork` called from
    `FlutterActivity.onResume`; the block was in the phone vendor's system hook,
    not in app code.
  - The Release build launched cleanly: `MainActivity` stayed focused, the
    process was still alive after 18 seconds, no ANR or fatal crash appeared,
    and the SMS permission is granted.
  - The Release build printed Kotlin metadata warnings (dependency metadata 1.8
    vs expected 1.6) but completed and runs. Watch the WorkManager path when
    forwarding is enabled.
- Behavior: `none` (build and install only).
- Business rules: `none`.
- Verification: `adb install` succeeded; `adb shell pidof`,
  `dumpsys window`, and logcat checks confirmed a stable foreground app with no
  ANR. End-to-end SMS forwarding is pending Twilio credentials on the phone.
- Commit: `docs(agent): install and launch Android app`



- Intent: Resume Android setup so the app can be tested on an Android device.
- Changed:
  - No tracked source changes.
  - Installed Temurin JDK 17 at
    `~/Library/Java/JavaVirtualMachines/temurin-17.jdk` after Homebrew began
    compiling CMake from source; the prebuilt JDK avoided that build.
  - Installed Android command-line tools and SDK packages under
    `~/Library/Android/sdk`: `platform-tools`, `platforms;android-34`, and
    `build-tools;34.0.0`. Gradle also installed build-tools 30.0.3.
  - Configured Flutter with the Android SDK and JDK paths.
  - `flutter clean` removed regenerable artifacts; `flutter pub get` restored
    the Flutter plugin files.
  - Built `build/app/outputs/flutter-apk/app-debug.apk` (403 MB universal
    debug APK).
- Behavior: `none` (tooling and build only).
- Business rules: `none`.
- Verification: `flutter doctor` reports the Android toolchain ready;
  `flutter analyze` found no issues; `flutter test` passed all 4 tests; the APK
  build completed successfully.
- Blocker: `adb devices` shows no connected Android device and no phone appears
  over USB, so the APK has not been installed or launched.
- Commit: `docs(agent): set up Android build and produce debug APK`



- Intent: Answer why automatic SMS forwarding exists on Android while iOS
  requires manual paste/type.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - iOS has no public API for reading the SMS inbox or receiving incoming SMS
    in the background. Apps can only open a prefilled Messages/WhatsApp
    composer, and the user must confirm and send.
  - iOS SMS filter extensions can classify/filter unknown senders but cannot
    forward message content. The entitled EU default-messaging API is a
    separate, limited path this app does not implement.
  - Android grants `RECEIVE_SMS` and lets a BroadcastReceiver queue work through
    WorkManager, which is why the Android flow can run with the screen off.
  - Google Play restricts SMS permissions, so the Android MVP is intended for
    private installation.
  - The iOS build uses the `whatsapp://send` deep link, not Twilio; the Android
    build submits through the Twilio WhatsApp API.
- Behavior: `none`.
- Business rules: `none`; BR-003 and BR-020 already record the iOS constraint.
- Verification: reviewed `lib/main.dart`, the Android receiver/worker, and the
  README platform notes; no commands were needed.
- Commit: `docs(agent): explain Android and iOS SMS capability gap`



- Intent: Answer how to share the app with an iPhone user in a different
  location.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - Free personal-team signing is bound to this Mac's registered devices and
    expires after seven days, so it cannot reach a remote iPhone.
  - TestFlight through the paid Apple Developer Program is the practical remote
    route. Internal testers avoid beta review; external testers can use a public
    link after Beta App Review. TestFlight builds expire after 90 days.
  - Ad Hoc is also possible with a paid membership, but it requires the
    recipient's device UDID and a manual install; sending only the `.app` file
    does not work.
  - The iOS build remains the manual WhatsApp compose flow; automatic SMS
    forwarding is Android-only.
- Behavior: `none`.
- Business rules: `none`.
- Verification: derived from the signing audit recorded in the 11:05 entry; no
  additional commands were needed.
- Commit: `docs(agent): recommend TestFlight for remote iPhone sharing`



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
