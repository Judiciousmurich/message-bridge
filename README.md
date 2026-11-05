# Message Bridge

Type or paste a message, then continue it in WhatsApp. You review the message
and tap Send there. The app does not read SMS and does not call Twilio.

## Run

Install Flutter and Xcode or the Android SDK, then run:

```sh
flutter pub get
flutter run
```

WhatsApp must be installed on the phone. The recipient field is optional: enter
an international number, or leave it blank and choose the chat in WhatsApp.

## Check

```sh
flutter analyze
flutter test
```

Build Android with `flutter build apk`. iOS builds require Xcode and signing.
The Android identifier is `com.actserv.message_bridge`. The partial Expo
starter is preserved in `.previous-expo/` and is unused by this app.
