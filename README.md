# Message Bridge

On Android, Message Bridge reads the SMS messages stored on the phone and
opens a chosen one in WhatsApp. You review it and tap Send there. The text is
not uploaded and Twilio is not used.

iPhone cannot do the same thing. Apple does not let a normal app read the
Messages inbox, including when the person would allow it. On iOS, copy a
message and paste it into Message Bridge, then continue in WhatsApp.

## Run

Install Flutter and Xcode or the Android SDK, then run:

```sh
flutter pub get
flutter run
```

On Android, grant SMS access when asked. WhatsApp must be installed. Leave the
recipient blank to choose the chat in WhatsApp, or enter an international
number.

The list shows the 200 newest received and sent texts. Google Play restricts
SMS access, so this build is meant for a private install. Some phones only let
the default Messages app read texts; if the list stays empty after you allow
access, the phone blocked the read.

## Check

```sh
flutter analyze
flutter test
```

Build Android with `flutter build apk`. iOS builds require Xcode and signing.
The Android identifier is `com.actserv.message_bridge`. The partial Expo
starter is preserved in `.previous-expo/` and is unused by this app.
