# Business Rules Ledger

This file is the source of truth for Message Bridge's externally observable
behavior and constraints. Read it before changing behavior. Update it only when
behavior intentionally changes, following the maintenance rules at the bottom.

Status values: `Active`, `Superseded`, `Retired`.

Kotlin source paths are relative to
`android/app/src/main/kotlin/com/actserv/message_bridge/`.

## Active rules

### BR-031 — Android lists texts and opens a chosen one in WhatsApp
- Status: Active
- Type: Behavior
- Rule: On Android, after the user grants SMS read permission, the app lists up
  to 200 of the newest received and sent SMS messages stored on that phone.
  The user can open a chosen text in WhatsApp Messenger with the text
  prefilled and then taps Send. The screen does not ask for Twilio. The app
  does not upload the texts or call Twilio.
- Source: `README.md`, `lib/sms_inbox_page.dart`, `MainActivity.kt`
- History:
  - 2026-11-12 — Restored the text list after the Twilio setup screen was
    rejected. Supersedes BR-026. Ledger: Restore the text list.

### BR-024 — iOS cannot read the Messages inbox
- Status: Active
- Type: Constraint
- Rule: On iOS, the app cannot read the Messages inbox. The user copies or
  types a message and opens WhatsApp Messenger with it prefilled, then taps
  Send.
- Source: `README.md`, `lib/compose_page.dart`
- History:
  - 2026-11-05 — Added because iOS provides no general API for reading SMS.
    Supersedes the shared-composer part of BR-022. Ledger: Read phone texts
    into WhatsApp.
  - 2026-11-05 — Kept after a request for the same inbox on iOS. A normal app
    still has no API for the Messages inbox. Ledger: Read Android texts; iOS
    inbox stays blocked.
  - 2026-11-06 — Automatic Twilio forwarding is Android-only. Ledger: Forward
    new SMS through Twilio.
  - 2026-11-12 — Android again shows the text list. iOS stays on paste. Ledger:
    Restore the text list.

## Superseded rules

### BR-026 — New SMS is forwarded automatically through Twilio
- Status: Superseded by BR-031
- Type: Behavior
- Rule: On Android, after the user saves the Twilio WhatsApp connection and
  enables forwarding, each new incoming SMS that passes the optional exact
  sender filter is queued and submitted to the configured WhatsApp number
  through Twilio. This runs while the app is closed and while the phone is
  locked, when Android allows the work. The user does not open the app, press
  Continue, or tap Send for that SMS. The app shows setup and status only. It
  does not list an inbox.
- Source: `README.md`, `SmsReceiver.kt`, `ForwardSmsWorker.kt`, `lib/automation_page.dart`
- History:
  - 2026-11-06 — Added for unattended SMS-to-WhatsApp forwarding. Supersedes
    BR-023. Ledger: Forward new SMS through Twilio.
  - 2026-11-12 — Superseded. The Twilio setup screen was removed and the text
    list returned. Ledger: Restore the text list.

### BR-027 — The phone's Messages app is left unchanged
- Status: Superseded by BR-031
- Type: Constraint
- Rule: Forwarding uses the new-SMS broadcast only. The app does not read,
  delete, or rewrite the existing Messages inbox, and it does not replace the
  phone's Messages app.
- Source: `README.md`, `SmsReceiver.kt`, `AndroidManifest.xml`
- History:
  - 2026-11-06 — Added with unattended forwarding. Ledger: Forward new SMS
    through Twilio.
  - 2026-11-12 — Superseded. The app lists stored texts again and does not
    delete them. Ledger: Restore the text list.

### BR-028 — Twilio secrets stay encrypted on the phone
- Status: Retired
- Type: Constraint
- Rule: The Account SID, auth token, sender, and recipient are entered on the
  phone. The token and a queued SMS body are encrypted with a device-bound
  key. They must not appear in logs, status text, the ledgers, or chat.
- Source: `README.md`, `ForwardingStore.kt`
- History:
  - 2026-11-06 — Added when Twilio forwarding returned. Ledger: Forward new
    SMS through Twilio.
  - 2026-11-12 — Retired. The app no longer collects Twilio credentials.
    Ledger: Restore the text list.

### BR-029 — An uncertain Twilio submission is not sent again
- Status: Retired
- Type: Behavior
- Rule: If a submission's outcome is unknown, the app must not send it again.
  The status tells the user to check Twilio's logs. "Accepted by Twilio" means
  the API accepted the message, not that WhatsApp delivered it.
- Source: `README.md`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-06 — Added when Twilio forwarding returned. Ledger: Forward new
    SMS through Twilio.
  - 2026-11-12 — Retired. The app no longer calls Twilio. Ledger: Restore the
    text list.

### BR-030 — SMS reception is for a private install
- Status: Superseded by BR-031
- Type: Constraint
- Rule: Receiving SMS requires a runtime permission. Google Play distribution
  needs eligibility and a permissions declaration. This build is for a private
  install. Android may delay background work, and force-stopping the app stops
  reception until it is opened again.
- Source: `README.md`, `AndroidManifest.xml`
- History:
  - 2026-11-06 — Added when forwarding uses the SMS broadcast again. Supersedes
    BR-025. Ledger: Forward new SMS through Twilio.
  - 2026-11-12 — Superseded. The app reads stored texts with permission and
    does not receive them in the background. Ledger: Restore the text list.

### BR-023 — Android lists texts and opens a chosen one in WhatsApp
- Status: Superseded by BR-026
- Type: Behavior
- Rule: On Android, after the user grants SMS read permission, the app lists up
  to 200 of the newest received and sent SMS messages stored on that phone.
  The user can edit one or open it in the phone's own WhatsApp with the text
  prefilled. The user reviews and taps Send in WhatsApp. The app does not
  upload the texts, store provider credentials, or call Twilio.
- Source: `README.md`, `lib/sms_inbox_page.dart`, `MainActivity.kt`
- History:
  - 2026-11-05 — Added so the Android app reads the phone's own SMS inbox.
    Supersedes the no-SMS part of BR-022. Ledger: Read phone texts into WhatsApp.
  - 2026-11-06 — Superseded. Android forwards new SMS through Twilio and no
    longer shows an inbox. Ledger: Forward new SMS through Twilio.

### BR-025 — SMS read access is for a private install
- Status: Superseded by BR-030
- Type: Constraint
- Rule: Reading SMS requires a runtime permission. Distribution through Google
  Play requires eligibility and a permissions declaration. This build is
  intended for private installation. If the phone only allows its default
  Messages app to read texts, the list stays empty.
- Source: `README.md`, `AndroidManifest.xml`
- History:
  - 2026-11-05 — Added with on-device SMS reading. Ledger: Read phone texts
    into WhatsApp.
  - 2026-11-06 — Superseded. The app receives new SMS broadcasts and does not
    list the inbox. Ledger: Forward new SMS through Twilio.

### BR-022 — Manual WhatsApp composer on every platform
- Status: Superseded by BR-023 and BR-024
- Type: Behavior
- Rule: On Android and iOS, the app shows one composer. The user types or
  pastes a message, optionally enters a recipient, and opens WhatsApp with the
  message prefilled. The user reviews and taps Send in WhatsApp. The app does
  not read SMS, receive SMS, store provider credentials, or call Twilio.
- Source: `README.md`, `lib/main.dart`
- History:
  - 2026-11-05 — Added when automatic Twilio forwarding was removed. Supersedes
    BR-003 and BR-021. Ledger: Remove automatic Twilio forwarding.
  - 2026-11-05 — Superseded. Android now reads on-device SMS. iOS keeps the
    manual composer. Ledger: Read phone texts into WhatsApp.

### BR-003 — iOS keeps the manual compose flow
- Status: Superseded by BR-022
- Type: Behavior
- Rule: Automatic SMS forwarding is Android-only. On iOS, the app keeps the
  original manual compose flow and sends nothing automatically.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Superseded. Both platforms now use the manual composer, and
    automatic forwarding is gone. Ledger: Remove automatic Twilio forwarding.

### BR-021 — Android offers a manual message composer
- Status: Superseded by BR-022
- Type: Behavior
- Rule: On Android, a Message tab lets the user type or paste a message,
  optionally enter a recipient, and open WhatsApp with the message prefilled.
  The user reviews and taps Send in WhatsApp. This path does not read SMS or
  call Twilio.
- Source: `lib/main.dart`
- History:
  - 2026-11-04 — Added with the Android two-tab composer/automation UI.
  - 2026-11-05 — Superseded. The Automatic tab is gone, and the composer is the
    whole app. Ledger: Remove automatic Twilio forwarding.

## Retired rules

### BR-001 — Android forwards new SMS automatically
- Status: Retired
- Type: Behavior
- Rule: On Android, a new incoming SMS that passes the sender filter is queued
  and submitted automatically to the configured WhatsApp recipient through
  Twilio's WhatsApp API. No copy, compose, WhatsApp launch, or Send tap is part
  of the flow.
- Source: `README.md`, `SmsReceiver.kt`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-002 — Forwarding works in the background
- Status: Retired
- Type: Behavior
- Rule: Forwarding must work while the app screen is not open and while the
  phone is locked. Pending SMS is submitted through WorkManager when a network
  connection is available.
- Source: `README.md`, `SmsReceiver.kt`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-004 — Sender filter is exact and optional
- Status: Retired
- Type: Behavior
- Rule: Forwarding can be restricted to one exact SMS sender. A blank filter
  forwards all new SMS, including sensitive messages, to the configured
  WhatsApp recipient.
- Source: `README.md`, `SmsReceiver.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-005 — Credentials stay on the device and out of logs
- Status: Retired
- Type: Constraint
- Rule: Twilio Account SID, auth token, sender number, and recipient number are
  entered on the phone, never in chat. The auth token must never appear in logs,
  status text, the ledgers, or commit messages.
- Source: `README.md`, `ForwardingStore.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. The app no longer collects Twilio credentials. Any
    previously stored token is cleared on the next Android launch. Ledger:
    Remove automatic Twilio forwarding.

### BR-006 — Stored secrets and queued SMS are encrypted
- Status: Retired
- Type: Constraint
- Rule: The Twilio token and queued SMS bodies are encrypted at rest with a
  device-bound Android Keystore key. Android app-data backup is disabled.
- Source: `README.md`, `ForwardingStore.kt`, `AndroidManifest.xml`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. The encrypted store and its key are removed on launch.
    Android app-data backup stays disabled. Ledger: Remove automatic Twilio
    forwarding.

### BR-007 — Duplicate SMS broadcasts are deduplicated
- Status: Retired
- Type: Behavior
- Rule: Repeated broadcasts of the same SMS are deduplicated using the sender,
  timestamp, and body fingerprint. Two separate messages with identical text
  remain distinct.
- Source: `README.md`, `SmsReceiver.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-008 — Pausing invalidates pending work
- Status: Retired
- Type: Behavior
- Rule: Pausing forwarding invalidates pending work. An HTTP submission already
  in progress may still complete after the pause.
- Source: `README.md`, `MainActivity.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-009 — Uncertain submissions are not resent automatically
- Status: Retired
- Type: Behavior
- Rule: When a network submission has an uncertain outcome, the app must not
  resend it automatically; doing so could duplicate a WhatsApp message. The
  status tells the operator to confirm the result in Twilio's logs.
- Source: `README.md`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-010 — Settings changes do not replay failed messages
- Status: Retired
- Type: Behavior
- Rule: Failed or unknown SMS submissions are not automatically replayed when
  forwarding settings are changed.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-011 — Inbox history is never read
- Status: Retired
- Type: Constraint
- Rule: The app does not read existing SMS inbox history. It handles only new
  incoming SMS broadcasts.
- Source: `README.md`, `AndroidManifest.xml`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. The app no longer receives SMS. BR-022 covers the
    remaining constraint. Ledger: Remove automatic Twilio forwarding.

### BR-012 — Forwarded SMS body limit is 1500 UTF-16 units
- Status: Retired
- Type: Behavior
- Rule: SMS longer than 1500 UTF-16 code units is not forwarded. The status
  reports that the message exceeded the MVP limit and that nothing was sent.
- Source: `README.md`, `SmsReceiver.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-013 — Free-form WhatsApp sending needs an open 24-hour session
- Status: Retired
- Type: Constraint
- Rule: The recipient must have messaged the Twilio WhatsApp Sandbox sender to
  open the 24-hour free-form session. Production sending outside that window
  requires approved WhatsApp templates, which this MVP does not implement.
- Source: `README.md`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-014 — Twilio acceptance is not delivery confirmation
- Status: Retired
- Type: Behavior
- Rule: The status "Accepted by Twilio" means the API accepted the submission,
  not that WhatsApp delivered the message.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-015 — Pending work survives ordinary app restarts
- Status: Retired
- Type: Behavior
- Rule: Queued forwarding work must survive ordinary app restarts.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-016 — Reboot requires one unlock
- Status: Retired
- Type: Constraint
- Rule: After a reboot, the phone must be unlocked once before the encrypted
  configuration becomes available to the forwarding flow.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-017 — Forwarding status is visible to the operator
- Status: Retired
- Type: Behavior
- Rule: The app shows the current forwarding status, including failures,
  expired sessions, and cases where delivery was not confirmed.
- Source: `README.md`, `MainActivity.kt`, `lib/automation_page.dart`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-018 — Android battery and force-stop limits are accepted
- Status: Retired
- Type: Constraint
- Rule: Android may delay WorkManager jobs in battery-saving modes. Force-stopping
  the app blocks SMS reception until the app is opened again. The app does not
  attempt to work around these platform limits.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. Automatic Twilio forwarding was removed. Ledger:
    Remove automatic Twilio forwarding.

### BR-019 — Google Play SMS permission eligibility is required
- Status: Retired
- Type: Constraint
- Rule: Distribution through Google Play requires eligibility and a permissions
  declaration for SMS access. The MVP is intended for private installation on a
  test device.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. The app no longer requests SMS access. Ledger:
    Remove automatic Twilio forwarding.

### BR-020 — iOS worldwide SMS access is out of scope
- Status: Retired
- Type: Constraint
- Rule: iOS has no general worldwide SMS access. The separate entitled
  default-carrier messaging API for eligible EU users is not implemented by this
  starter.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.
  - 2026-11-05 — Retired. The app no longer has an SMS feature on any platform.
    Ledger: Remove automatic Twilio forwarding.

## Maintenance

When changing a rule:

1. Keep the stable ID. Never renumber or reuse an ID.
2. Do not delete an active rule. Mark it `Superseded` and add the replacement
   with the next free ID, or mark it `Retired` if it no longer applies.
3. Add a `History` line with the date, the reason, and the related change-ledger
   entry title.
4. Reference the affected IDs in `docs/change-ledger.md`.
