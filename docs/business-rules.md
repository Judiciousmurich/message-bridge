# Business Rules Ledger

This file is the source of truth for Message Bridge's externally observable
behavior and constraints. Read it before changing behavior. Update it only when
behavior intentionally changes, following the maintenance rules at the bottom.

Status values: `Active`, `Superseded`, `Retired`.

Kotlin source paths are relative to
`android/app/src/main/kotlin/com/actserv/message_bridge/`.

## Active rules

### BR-001 — Android forwards new SMS automatically
- Status: Active
- Type: Behavior
- Rule: On Android, a new incoming SMS that passes the sender filter is queued
  and submitted automatically to the configured WhatsApp recipient through
  Twilio's WhatsApp API. No copy, compose, WhatsApp launch, or Send tap is part
  of the flow.
- Source: `README.md`, `SmsReceiver.kt`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-002 — Forwarding works in the background
- Status: Active
- Type: Behavior
- Rule: Forwarding must work while the app screen is not open and while the
  phone is locked. Pending SMS is submitted through WorkManager when a network
  connection is available.
- Source: `README.md`, `SmsReceiver.kt`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-003 — iOS keeps the manual compose flow
- Status: Active
- Type: Behavior
- Rule: Automatic SMS forwarding is Android-only. On iOS, the app keeps the
  original manual compose flow and sends nothing automatically.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-004 — Sender filter is exact and optional
- Status: Active
- Type: Behavior
- Rule: Forwarding can be restricted to one exact SMS sender. A blank filter
  forwards all new SMS, including sensitive messages, to the configured
  WhatsApp recipient.
- Source: `README.md`, `SmsReceiver.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-005 — Credentials stay on the device and out of logs
- Status: Active
- Type: Constraint
- Rule: Twilio Account SID, auth token, sender number, and recipient number are
  entered on the phone, never in chat. The auth token must never appear in logs,
  status text, the ledgers, or commit messages.
- Source: `README.md`, `ForwardingStore.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-006 — Stored secrets and queued SMS are encrypted
- Status: Active
- Type: Constraint
- Rule: The Twilio token and queued SMS bodies are encrypted at rest with a
  device-bound Android Keystore key. Android app-data backup is disabled.
- Source: `README.md`, `ForwardingStore.kt`, `AndroidManifest.xml`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-007 — Duplicate SMS broadcasts are deduplicated
- Status: Active
- Type: Behavior
- Rule: Repeated broadcasts of the same SMS are deduplicated using the sender,
  timestamp, and body fingerprint. Two separate messages with identical text
  remain distinct.
- Source: `README.md`, `SmsReceiver.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-008 — Pausing invalidates pending work
- Status: Active
- Type: Behavior
- Rule: Pausing forwarding invalidates pending work. An HTTP submission already
  in progress may still complete after the pause.
- Source: `README.md`, `MainActivity.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-009 — Uncertain submissions are not resent automatically
- Status: Active
- Type: Behavior
- Rule: When a network submission has an uncertain outcome, the app must not
  resend it automatically; doing so could duplicate a WhatsApp message. The
  status tells the operator to confirm the result in Twilio's logs.
- Source: `README.md`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-010 — Settings changes do not replay failed messages
- Status: Active
- Type: Behavior
- Rule: Failed or unknown SMS submissions are not automatically replayed when
  forwarding settings are changed.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-011 — Inbox history is never read
- Status: Active
- Type: Constraint
- Rule: The app does not read existing SMS inbox history. It handles only new
  incoming SMS broadcasts.
- Source: `README.md`, `AndroidManifest.xml`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-012 — Forwarded SMS body limit is 1500 UTF-16 units
- Status: Active
- Type: Behavior
- Rule: SMS longer than 1500 UTF-16 code units is not forwarded. The status
  reports that the message exceeded the MVP limit and that nothing was sent.
- Source: `README.md`, `SmsReceiver.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-013 — Free-form WhatsApp sending needs an open 24-hour session
- Status: Active
- Type: Constraint
- Rule: The recipient must have messaged the Twilio WhatsApp Sandbox sender to
  open the 24-hour free-form session. Production sending outside that window
  requires approved WhatsApp templates, which this MVP does not implement.
- Source: `README.md`, `ForwardSmsWorker.kt`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-014 — Twilio acceptance is not delivery confirmation
- Status: Active
- Type: Behavior
- Rule: The status "Accepted by Twilio" means the API accepted the submission,
  not that WhatsApp delivered the message.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-015 — Pending work survives ordinary app restarts
- Status: Active
- Type: Behavior
- Rule: Queued forwarding work must survive ordinary app restarts.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-016 — Reboot requires one unlock
- Status: Active
- Type: Constraint
- Rule: After a reboot, the phone must be unlocked once before the encrypted
  configuration becomes available to the forwarding flow.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-017 — Forwarding status is visible to the operator
- Status: Active
- Type: Behavior
- Rule: The app shows the current forwarding status, including failures,
  expired sessions, and cases where delivery was not confirmed.
- Source: `README.md`, `MainActivity.kt`, `lib/automation_page.dart`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-018 — Android battery and force-stop limits are accepted
- Status: Active
- Type: Constraint
- Rule: Android may delay WorkManager jobs in battery-saving modes. Force-stopping
  the app blocks SMS reception until the app is opened again. The app does not
  attempt to work around these platform limits.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-019 — Google Play SMS permission eligibility is required
- Status: Active
- Type: Constraint
- Rule: Distribution through Google Play requires eligibility and a permissions
  declaration for SMS access. The MVP is intended for private installation on a
  test device.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-020 — iOS worldwide SMS access is out of scope
- Status: Active
- Type: Constraint
- Rule: iOS has no general worldwide SMS access. The separate entitled
  default-carrier messaging API for eligible EU users is not implemented by this
  starter.
- Source: `README.md`
- History:
  - 2026-11-04 — Initial record seeded from `README.md`.

### BR-021 — Android offers a manual message composer
- Status: Active
- Type: Behavior
- Rule: On Android, a Message tab lets the user type or paste a message,
  optionally enter a recipient, and open WhatsApp with the message prefilled.
  The user reviews and taps Send in WhatsApp. This path does not read SMS or
  call Twilio.
- Source: `lib/main.dart`
- History:
  - 2026-11-04 — Added with the Android two-tab composer/automation UI.

## Maintenance

When changing a rule:

1. Keep the stable ID. Never renumber or reuse an ID.
2. Do not delete an active rule. Mark it `Superseded` and add the replacement
   with the next free ID, or mark it `Retired` if it no longer applies.
3. Add a `History` line with the date, the reason, and the related change-ledger
   entry title.
4. Reference the affected IDs in `docs/change-ledger.md`.
