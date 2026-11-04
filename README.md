# Message Bridge

Android MVP automatically forwards incoming SMS through the Twilio WhatsApp
API. The Flutter screen configures the connection and recipient. A manifest
receiver receives SMS even after leaving the screen, and WorkManager submits
it when internet is available. iOS retains the original manual compose flow.

## Run

Install Flutter and Xcode or the Android SDK, then run:

```sh
flutter pub get
flutter run
```

## Android test setup

1. Create a Twilio account and activate its WhatsApp Sandbox. The account may
   require verification or credit according to Twilio's current trial terms.
2. From the destination WhatsApp account, join that Sandbox using the provided
   join code and send it a message. This opens the 24-hour free-form messaging
   session required for the prototype. Production sending outside that window
   requires approved WhatsApp templates, which this MVP does not implement.
3. Install the APK on the Android phone that will receive the SMS. In Message
   Bridge enter the Account SID, auth token, Sandbox sender number, and
   destination WhatsApp number. Enter credentials on the phone, not in chat.
4. Optionally restrict forwarding to one exact SMS sender. Blank forwards all
   new SMS, including sensitive messages, to the configured WhatsApp recipient.
5. Save the connection and enable automatic forwarding. Grant SMS permission.
6. Lock the Android phone and send it a short SMS from another phone. No copy,
   compose, WhatsApp launch, or Send tap is part of this forwarding flow. Refresh
   the app's status and check Twilio message logs and the receiving WhatsApp.

Reference: https://www.twilio.com/docs/whatsapp/quickstart

This MVP sends from the Twilio WhatsApp sender, not the Android phone's personal
WhatsApp identity. WhatsApp need not be installed on the sending Android phone.
Android may delay jobs during battery-saving modes. Force-stopping the app
blocks SMS reception until it is opened again. After reboot, unlock the phone
once to make the encrypted configuration available. Inbox history is not read.

Tokens and pending SMS bodies are encrypted with Android Keystore. This direct
API connection is for a privately installed test device. A distributed product
should keep provider credentials on an authenticated backend. Backup of app
data is disabled. Maximum forwarded SMS body length is 1500 UTF-16 units.

Repeated SMS broadcasts are deduplicated. Pending work survives ordinary app
restarts. Pausing invalidates pending work, though an HTTP submission already
in progress may complete. Uncertain network submissions are not automatically
resent to avoid duplicate WhatsApp messages. Confirm those in Twilio's logs.
The status 'Accepted by Twilio' means API acceptance, not confirmed delivery.
Failed/unknown SMS are not automatically replayed when settings are changed.

Google Play restricts SMS permissions; distribution requires eligibility and a
permissions declaration. iOS general worldwide SMS access is unavailable;
Apple offers a separate entitled default carrier messaging API for eligible EU
users, which this starter does not implement.

## Check

```sh
flutter analyze
flutter test
```

On an Android test phone verify the locked-screen flow above, permission
denial/revocation, sender filtering, multipart SMS, pause, expired sessions,
offline reception then reconnect, and process restart. Live WhatsApp delivery
requires valid credentials and is not covered by widget tests. Inspect Twilio's
message logs for delivery failures. The API token must never appear in logs.

Build Android with `flutter build apk`. iOS builds require Xcode and signing.
The Android identifier is `com.actserv.message_bridge`. The partial Expo
starter is preserved in `.previous-expo/` and is unused by this app.
