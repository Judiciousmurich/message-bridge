# Message Bridge

On Android, Message Bridge watches for a new SMS and sends its text to a
WhatsApp number through Twilio. After setup, this happens while the app is
closed and while the phone is locked. The original text stays in the phone's
Messages app. The app does not show an inbox and does not ask you to continue
each message.

iPhone cannot receive SMS inside an app, so automatic forwarding is Android-only.

## Run

Install Flutter and the Android SDK, then run:

```sh
flutter pub get
flutter run
```

## Android setup

1. Create a Twilio account and activate its WhatsApp Sandbox.
2. From the WhatsApp account that should receive the texts, join that Sandbox
   and send it a message. That opens the 24-hour session. The message arrives
   from the Sandbox number.
3. Install Message Bridge on the Android phone that receives the SMS. Enter the
   Account SID, auth token, Sandbox sender, and your WhatsApp number on the
   phone. Do not enter them in chat.
4. Leave the sender filter blank to forward every new SMS, or set one exact
   sender. Save, enable forwarding, and grant SMS permission.
5. Lock the phone and send it an SMS. Refresh the status in the app, and check
   Twilio's logs and the receiving WhatsApp.

The app reads only the new SMS broadcast. It does not open, delete, or rewrite
the Messages inbox. Android may delay background work. Force-stopping the app
blocks reception until it is opened again. After reboot, unlock the phone once
so the encrypted settings are available.

The token and a queued SMS body are encrypted with Android Keystore. Backup of
app data is disabled. The maximum forwarded body is 1500 UTF-16 units. A
submission whose result is uncertain is not sent again. "Accepted by Twilio"
means the API accepted it, not that WhatsApp has delivered it.

Google Play restricts SMS permission. This build is for a private install.

## Check

```sh
flutter analyze
flutter test
```

Build Android with `flutter build apk`. The Android identifier is
`com.actserv.message_bridge`. The partial Expo starter in `.previous-expo/` is
unused.
