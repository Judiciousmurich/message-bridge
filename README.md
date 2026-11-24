# Message Bridge

Message Bridge helps you open a text in WhatsApp Messenger. Copy a message
from your Messages app (or type one), save your WhatsApp number once, tap
Continue in WhatsApp, then tap Send in WhatsApp. The app does not upload your
text and does not use Twilio.

On Android and iPhone the flow is the same: the app does **not** read your SMS
inbox. That keeps the Google Play build within Play policy (no `READ_SMS`).

## Run

Install Flutter and Xcode or the Android SDK, then run:

```sh
flutter pub get
flutter run
```

Enter your WhatsApp number once. A number starting with 07 or 01 is saved as
+254. Spaces are fine. WhatsApp must be installed on Android.

## Privacy policy

The policy text lives in [`docs/privacy-policy.md`](docs/privacy-policy.md) and
[`docs/privacy-policy.html`](docs/privacy-policy.html). For Play Console, host the
HTML on a public HTTPS URL (for example jsDelivr from the public GitHub repo on
`main`) and paste that URL into the privacy policy declaration.

## Play Store (Android)

1. Build: `flutter build appbundle --release` (needs free disk space).
2. Optional upload key: copy `android/key.properties.example` to
   `android/key.properties`, create `android/app/upload-keystore.jks`, then
   rebuild. Without `key.properties`, release uses the debug key (Play may
   reject or require Play App Signing enrollment).
3. Play Console → **Test and release** → upload the new AAB (version code **5**
   or higher after SMS removal), roll out to **Production**, then **Submit for
   review**.
4. **App content**: remove the **SMS and call log** permissions declaration if
   the bundle no longer requests SMS permissions.
5. **Data safety**: answer **No** for collection/sharing; save on Preview.

## Check

```sh
flutter analyze
flutter test
```