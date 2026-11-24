# Message Bridge

Message Bridge helps a **WhatsApp group treasurer** track M-Pesa contributions
without reading the SMS inbox (Google Play–friendly).

1. In Messages, **Share** the M-Pesa SMS to Message Bridge, or **copy** and tap
   **Paste M-Pesa SMS**.
2. Or tap **Add payment manually** if there is no SMS.
3. Totals are **saved on the phone**. Copy a group update or open **WhatsApp**
   (you tap Send). Use **Thank in WhatsApp** per payer when a number is known.

There is also a **Compose** screen to paste any text and continue in WhatsApp.
No `READ_SMS`, no uploads, no Twilio.

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