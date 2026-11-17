# Message Bridge

On Android, Message Bridge lists the texts on the phone. You save your
WhatsApp number once. Tap a text and WhatsApp opens with that text filled in
for that number. You tap Send. The text is not uploaded and Twilio is not used.

iPhone cannot do the same thing. Apple does not let a normal app read the
Messages inbox, including when the person would allow it. On iOS, copy a
message and paste it into Message Bridge, then continue in WhatsApp.

## Run

Install Flutter and Xcode or the Android SDK, then run:

```sh
flutter pub get
flutter run
```

On Android, grant SMS access when asked. Enter your WhatsApp number once.
A number starting with 07 or 01 is saved as +254. Spaces are fine.
WhatsApp must be installed. Tap one text, or tap Send today's texts to open
that day's texts together. You tap Send once in WhatsApp. Copy all texts
copies every listed text.

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
