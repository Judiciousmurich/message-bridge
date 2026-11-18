# Change Ledger

Append-only record of agent work. Newest entries first. One entry per turn.
Business rules are tracked separately in
[`business-rules.md`](business-rules.md).

## 2026-11-18 12:00 — How a Play build can be accepted
- Intent: The user asked how to get Play to accept Message Bridge.
- Changed: `docs/change-ledger.md` records the two honest paths. No application code changed.
- Findings: A Play build that does not request `READ_SMS` matches the permission rules. A build that reads SMS has to be the phone's real default Messages app. The private install can keep the current text list.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): record the Play acceptance paths`

## 2026-11-18 11:59 — Play rejection is not certain
- Intent: The user asked whether Play is certain to reject Message Bridge.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: Rejection is not certain. The review happens after submission. The risk remains `READ_SMS`, because the app is not the phone's default Messages app.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): say the Play review result is unknown`

## 2026-11-18 11:57 — Why Play may reject the SMS permission
- Intent: The user asked why the Play submission can be denied.
- Changed: `docs/change-ledger.md` records the reason. No application code changed.
- Findings: The app requests `READ_SMS` so it can list texts and open them in WhatsApp. Play limits that permission to a default SMS app or a narrow approved use. Message Bridge is not the phone's default Messages app.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only). Checked `AndroidManifest.xml` for `READ_SMS`.
- Commit: `docs(android): explain the SMS review risk`

## 2026-11-18 11:55 — Access does not upload the release
- Intent: The user asked whether granted Play access means the app can be built and deployed.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: Edit access allows the declarations to be saved. A release still needs those declarations saved, the Play App Signing terms accepted, and a signed Android App Bundle. The current release build uses the debug signing config.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): separate Play access from the release upload`

## 2026-11-18 11:52 — What still needs the Play administrator
- Intent: The user asked whether the account administrator is still needed after the declarations are filled.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: The declarations can be saved by an account that is allowed to edit them. Uploading a release still needs the account owner or an account administrator to accept the Play App Signing terms. A page that says edit permission is required also needs that person to grant access.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): note the remaining administrator step`

## 2026-11-18 11:51 — Declarations do not publish the app
- Intent: The user asked whether completing the declarations that need attention is enough to deploy.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: The declarations are required before a release. A release still needs a signed Android App Bundle, and Play can reject the app because it reads SMS. The current release build uses the debug signing config.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): explain the remaining Play release steps`

## 2026-11-18 11:48 — Play setup cannot be edited
- Intent: The user asked for the Play setup details to be filled in and for the app to be deployed.
- Changed: `docs/change-ledger.md` records the block. No application code changed.
- Findings: The Ads page opens, and both answers and Save are disabled. Play says this account needs permission to edit the page. The setup cannot be saved or published from this sign-in.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only). The Ads declaration page was opened while signed in.
- Commit: `docs(android): note the Play edit permission block`

## 2026-11-18 11:42 — Where the Ads task is
- Intent: The user asked where to get the ads for the Play setup.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: Message Bridge has no ads. The Ads task is a yes-or-no question on the app dashboard, not on Publishing overview and not under Monetise with Play. Publishing overview says this account cannot edit that page.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): point to the Ads setup task`

## 2026-11-18 11:39 — Next step for the Play draft
- Intent: The user asked what to do now that Play Console is signed in.
- Changed: `docs/change-ledger.md` records the next step. No application code changed.
- Findings: Finish the 12 setup tasks before a production release. The app reads SMS, which Play restricts, so a public listing can still be rejected. The phone already has a private install.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): record the next Play step`

## 2026-11-18 11:35 — Play Console is signed in
- Intent: The user signed in and the Play Console home could be opened.
- Changed: `docs/change-ledger.md` records the dashboard. No application code changed.
- Findings: Message Bridge is visible and still a draft. Production is locked until the initial setup tasks are done. None of the 12 store-setup tasks are complete. Release builds still use the debug signing config.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only). The signed-in dashboard was opened and the setup task list was expanded.
- Commit: `docs(android): note the signed-in Play dashboard`

## 2026-11-18 10:22 — Play Console home still needs sign-in
- Intent: The user sent the Play Console home link.
- Changed: `docs/change-ledger.md` records the result. No application code changed.
- Findings: The home link redirects to Google sign-in. This session is not signed into the Play account, so the app list is not visible from here.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only). The home URL redirected to Google sign-in.
- Commit: `docs(android): note the Play home sign-in`

## 2026-11-17 17:54 — Play dashboard needs a Google sign-in
- Intent: The user asked to deploy Message Bridge from the Play Console app dashboard.
- Changed: `docs/change-ledger.md` records the block. No application code changed.
- Findings: Opening the dashboard reaches a Google sign-in page. This session is not signed into the Play account. Release builds still use the debug signing config, so there is no Play upload bundle yet.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only). The dashboard URL redirected to Google sign-in.
- Commit: `docs(android): note the Play dashboard sign-in`

## 2026-11-17 17:47 — Play app exists as a draft
- Intent: The user showed that Message Bridge now exists in Google Play Console.
- Changed: `docs/change-ledger.md` records the draft. No application code changed.
- Findings: The listing is Message Bridge, package `com.actserv.message_bridge`, status Draft, last updated 17 Nov 2026. That package matches `applicationId`. Release builds still use the debug signing config, so this project cannot upload a Play release yet.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only). Compared the listing with `android/app/build.gradle`.
- Commit: `docs(android): note the Play app draft`

## 2026-11-17 17:40 — Push main to GitHub
- Intent: The user asked to push the project to GitHub.
- Changed: `main` on `https://github.com/Judiciousmurich/message-bridge.git` moved from `668ef1e` to `5670964`. No application code changed.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: `git push origin main` completed, `668ef1e..5670964`.
- Commit: `docs(agent): record the GitHub push`

## 2026-11-17 17:36 — Restore dropped ledger entries
- Intent: Four earlier entries were missing from the ledger file after today's batch was recorded.
- Changed: `docs/change-ledger.md` puts those entries back. `docs/business-rules.md` keeps both BR-033 history lines.
- Behavior: none.
- Business rules: BR-033 updated.
- Verification: not run (docs only).
- Commit: `docs(rules): restore dropped ledger entries`

## 2026-11-17 17:35 — Send today's texts together
- Intent: Opening one text at a time is too slow when many texts arrived today.
- Changed: `lib/sms_inbox_page.dart` can send today's texts as one WhatsApp message and copy every listed text. `lib/compose_page.dart` can open the saved chat without a prefilled message when the bundle is long. `README.md`, `docs/business-rules.md`, and `test/sms_inbox_test.dart` match.
- Behavior: One tap still opens one text. Send today's texts opens that day's texts together for one Send tap. A long day is copied so it can be pasted once. Copy all texts copies the whole list.
- Business rules: BR-033 added.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (8 tests). `flutter build apk --debug --target-platform android-arm` built `app-debug.apk`. `adb install -r` reported Success. `am start` opened `com.actserv.message_bridge/.MainActivity`.
- Commit: `feat(ui): send today's texts together`

## 2026-11-17 17:26 — Steps for the locked Play signing checkbox
- Intent: The user asked to continue and accept the Play App Signing terms as an admin. The checkbox on the Create app page is locked.
- Changed: `docs/change-ledger.md` records the next step. No application code changed.
- Findings: This signed-in account cannot tick the box. The developer account owner signs in on the same Create app page and ticks it, or grants this account account-admin permission under Users and permissions.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): record the Play signing acceptance steps`

## 2026-11-17 17:23 — The Play signing checkbox is locked
- Intent: The Create app page shows the Play App Signing checkbox locked, with a message to contact the account owner or administrator.
- Changed: `docs/change-ledger.md` records the locked checkbox. No application code changed.
- Findings: The signed-in account cannot tick Accept the Play app signing Terms of Service. The account owner has to sign in on this page and tick it, or grant this account account-admin permission.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): note the locked Play signing checkbox`

## 2026-11-17 17:22 — Where an admin accepts Play signing terms
- Intent: The user is an admin and still cannot accept the Play App Signing Terms of Service.
- Changed: `docs/change-ledger.md` records where those terms are accepted. No application code changed.
- Findings: Accepting the terms needs the Play account owner or an account admin. An admin of this app alone cannot accept them. The account owner accepts them under Protected with Play, Play Store protection, Manage Play app signing, or in the Declarations section while creating the app.
- Behavior: none.
- Business rules: none. BR-032 and BR-033 still apply.
- Verification: not run (docs only).
- Commit: `docs(android): note where Play signing terms are accepted`

## 2026-11-17 17:21 — Copy or open every listed text
- Intent: The user can open one text, and also wants every listed text copied or sent to the saved WhatsApp number without tapping each one.
- Changed: `lib/sms_inbox_page.dart` adds Copy all texts and Open all in WhatsApp. `lib/compose_page.dart` can open the saved chat with an empty draft when the combined text is too long. `README.md`, `docs/business-rules.md`, and `test/sms_inbox_test.dart` match.
- Behavior: One tap still opens one text. Copy all copies the list, oldest first. Open all puts that list in the saved WhatsApp chat. If it is longer than one draft, the list is copied and the chat opens so the user can paste, then tap Send.
- Business rules: BR-033 added.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (8 tests). The new build was not installed on the phone.
- Commit: `feat(ui): copy or open every listed text`

## 2026-11-17 17:11 — Accept the saved WhatsApp number
- Intent: A saved number was rejected on tap unless it was a plus followed by digits with no spaces.
- Changed: `lib/compose_page.dart` accepts `+254…` and a Kenyan `07` or `01` mobile. `lib/sms_inbox_page.dart` uses that check before opening WhatsApp. `README.md`, `docs/business-rules.md`, and the tests match.
- Behavior: Tapping a text opens WhatsApp when the saved number uses `+` or starts with `07`. A `07` number is stored as `+254`.
- Business rules: BR-032 updated.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (6 tests). `flutter build apk --debug --target-platform android-arm` built `app-debug.apk`. `adb install -r` reported Success. `am start` opened `com.actserv.message_bridge/.MainActivity`.
- Commit: `fix(ui): accept +254 and 07 WhatsApp numbers`

## 2026-11-17 17:06 — Run the app on the connected phone
- Intent: The user connected the itel A667L and asked to run the project.
- Changed: Built and installed the current debug app. No source files changed.
- Behavior: none. The phone is showing the restored text list.
- Business rules: none. BR-032 and BR-024 still apply.
- Verification: `flutter build apk --debug --target-platform android-arm` built `app-debug.apk`. `adb install -r` reported Success. `am start` opened `com.actserv.message_bridge/.MainActivity`, and that activity is resumed.
- Commit: `chore(android): run the app on the connected phone`

## 2026-11-17 17:02 — Revert the editorial restyle
- Intent: The careers-page design was applied to the wrong project. Put the text list back.
- Changed: Removed `lib/bridge_look.dart`, the desk photo, and the Instrument Serif font. Restored `lib/sms_inbox_page.dart`, `lib/compose_page.dart`, `lib/main.dart`, `pubspec.yaml`, and `test/sms_inbox_test.dart`.
- Behavior: The text list looks as it did before the restyle. Tapping a text still opens the saved WhatsApp chat.
- Business rules: none. BR-032 and BR-024 still apply.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (4 tests).
- Commit: `revert(ui): remove the editorial restyle`

## 2026-11-17 17:01 — Restyle the text list
- Intent: Give Message Bridge the warm editorial layout from the reference, including a photo and a clear empty state.
- Changed: `lib/bridge_look.dart`, `lib/sms_inbox_page.dart`, `lib/compose_page.dart`, and `lib/main.dart` use the new layout. `assets/images/desk.jpg` is the header photo. `assets/fonts/InstrumentSerif-Regular.ttf` is the headline face, with its OFL license. `pubspec.yaml` registers both. `test/sms_inbox_test.dart` covers the empty list.
- Behavior: An empty text list says "No texts on this phone." Tapping a text still opens it in the saved WhatsApp chat. The app does not list job roles.
- Business rules: none. BR-032 and BR-024 still apply.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (5 tests).
- Commit: `feat(ui): restyle the text list`

## 2026-11-17 16:51 — Play app signing terms need an admin
- Intent: Play Console says the signed-in user cannot accept the Play App Signing Terms of Service.
- Changed: `docs/change-ledger.md` records the block. No application code changed.
- Findings: Only the developer account owner or an administrator can accept those terms. Release builds in `android/app/build.gradle` still use the debug signing config.
- Behavior: none.
- Business rules: none. BR-032 still applies.
- Verification: not run (docs only).
- Commit: `docs(android): note the Play signing terms block`

## 2026-11-17 16:47 — Fill the Play Console create form
- Intent: The user started creating Message Bridge in Google Play Console and needs the form values.
- Changed: `docs/change-ledger.md` records the values. No application code changed.
- Findings: App name is Message Bridge. Package name is `com.actserv.message_bridge`. Type is App and price is Free. The app requests `READ_SMS`, which Play restricts and requires a permissions declaration.
- Behavior: none.
- Business rules: none. BR-032 still applies.
- Verification: not run (docs only). Compared the form with `android/app/build.gradle` and `AndroidManifest.xml`.
- Commit: `docs(android): fill the Play Console create form`

## 2026-11-12 13:20 — Open a tapped text in WhatsApp
- Intent: A text shown in Message Bridge should open in WhatsApp already filled in, leaving only Send.
- Changed: `lib/sms_inbox_page.dart` saves one WhatsApp number and opens that chat when a text is tapped. `MainActivity.kt` stores the number on the phone. `README.md` and `docs/business-rules.md` match.
- Behavior: After the number is saved, tapping a text opens WhatsApp with that text filled in. The user taps Send. The app does not call Twilio.
- Business rules: BR-031 superseded by BR-032.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (4 tests). `flutter build apk --debug --target-platform android-arm` built `app-debug.apk`. `adb install` failed because no phone was attached.
- Commit: `feat(android): open a tapped text in WhatsApp`

## 2026-11-12 11:40 — Restore the text list
- Intent: Remove the Twilio setup screen and show the previous text list that opens WhatsApp Messenger.
- Changed: Removed the Twilio receiver, worker, store, and setup screen. Restored `lib/sms_inbox_page.dart` and the SMS read channel. Updated `README.md` and `docs/business-rules.md`.
- Changed: Installed the new debug build on the itel A667L and opened it.
- Behavior: Android lists stored texts and opens a chosen one in WhatsApp Messenger. The user taps Send. The app does not call Twilio. iOS stays on paste.
- Business rules: BR-026 and BR-030 superseded by BR-031. BR-027 superseded by BR-031. BR-028 and BR-029 retired. BR-024 updated.
- Verification: `flutter analyze` reported no issues. The first `flutter test` failed because the disk was full; after freeing generated build files, `flutter test` passed (4 tests). `flutter build apk --debug --target-platform android-arm` built `app-debug.apk`. `adb install -r` succeeded and `am start` launched `MainActivity`. `READ_SMS` is not granted yet.
- Commit: `feat(android): restore the text list`

## 2026-11-12 11:25 — Install forwarding build on the phone
- Intent: The Android phone is connected, so install the Twilio forwarding build and open it.
- Changed: Installed `app-debug.apk` on the itel A667L and launched Message Bridge. `docs/change-ledger.md` records the install.
- Findings: The previous install was the November 5 build with `READ_SMS` granted. The new build is installed. `RECEIVE_SMS` is not granted yet. No message contents or Twilio credentials were read.
- Behavior: The setup screen is open. Forwarding starts after the user saves the Twilio connection, enables it, and allows SMS access.
- Business rules: none. BR-026 applies after that setup.
- Verification: `adb devices` showed the itel phone. `adb install -r` succeeded. `am start` launched `MainActivity`. `dumpsys package` showed `RECEIVE_SMS` granted false.
- Commit: `docs(android): install forwarding build on the phone`

## 2026-11-10 16:23 — Check whether texts are already forwarding
- Intent: Answer whether all messages are now being sent to WhatsApp.
- Changed: `docs/change-ledger.md` records the check. No application code changed.
- Findings: The phone is not connected. The built behavior forwards only a new SMS after Twilio is saved and forwarding is enabled. Existing Messages are not sent. No live delivery was observed.
- Behavior: none.
- Business rules: none. BR-026 and BR-027 still apply.
- Verification: `flutter devices` listed macOS and Chrome only.
- Commit: `docs(android): check whether texts are already forwarding`

## 2026-11-06 18:19 — Forward new SMS through Twilio
- Intent: Forward each new Android SMS to a WhatsApp number through Twilio with no per-message tap, and leave the phone's Messages app unchanged.
- Changed: Restored the SMS receiver, WorkManager submission, encrypted Twilio store, and setup screen. Removed the SMS inbox screen.
- Changed: `AndroidManifest.xml` receives new SMS and declares network access. `build.gradle` includes WorkManager. `README.md` and `docs/business-rules.md` match this flow.
- Behavior: After setup, a new SMS is sent to the configured WhatsApp number while the app is closed or the phone is locked. The original SMS stays in Messages. iOS has no automatic path.
- Business rules: BR-023 superseded by BR-026. BR-025 superseded by BR-030. BR-027, BR-028, and BR-029 added. BR-024 updated.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (4 tests). `flutter build apk --debug` built `app-debug.apk`.
- Commit: `feat(android): forward new SMS through Twilio`

## 2026-11-06 18:00 — Stay with WhatsApp Messenger
- Intent: The user wants the phone's WhatsApp Messenger app only, not a business API.
- Changed: `docs/change-ledger.md` records the decision. No application code changed.
- Findings: The app already opens WhatsApp Messenger with `whatsapp://send` and does not call Twilio or the Meta Cloud API. The user taps Send in WhatsApp.
- Behavior: none.
- Business rules: none. BR-023 and BR-024 still apply.
- Verification: not run (docs only). Reviewed `lib/compose_page.dart`.
- Commit: `docs(agent): stay with WhatsApp Messenger`

## 2026-11-06 17:53 — Explain the official WhatsApp API
- Intent: The user wants the ready-made WhatsApp API instead of Twilio.
- Changed: `docs/change-ledger.md` records the explanation. No application code changed.
- Findings: WhatsApp's own Cloud API is Meta's API, not a built-in part of the WhatsApp app and not Twilio. Using it still requires a Meta WhatsApp Business setup, and the token and sender are entered on the phone. Messages come from that business number.
- Behavior: none.
- Business rules: none. BR-023 still applies.
- Verification: not run (docs only).
- Commit: `docs(agent): explain the official WhatsApp API`

## 2026-11-06 17:47 — Explain Twilio versus the WhatsApp API
- Intent: Answer whether the user must configure Twilio, or whether the WhatsApp API includes Twilio.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: WhatsApp's API does not include Twilio. Twilio is a separate service that sends through WhatsApp's API. This app's removed automatic path used Twilio, so automatic sending here means a Twilio account configured on the phone.
- Behavior: none.
- Business rules: none. BR-023 still applies.
- Verification: not run (docs only).
- Commit: `docs(agent): explain Twilio versus the WhatsApp API`

## 2026-11-06 17:32 — Confirm a WhatsApp API can be used
- Intent: Answer whether Message Bridge can use a WhatsApp API for automatic delivery.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: Yes. A WhatsApp API can send a text to the user's WhatsApp number without the Send tap. This project previously used Twilio's WhatsApp API. That code is removed. The phone's WhatsApp app is still the no-API path. Credentials would be entered on the phone.
- Behavior: none.
- Business rules: none. BR-023 still applies until an API path is added again.
- Verification: not run (docs only).
- Commit: `docs(android): confirm a WhatsApp API can be used`

## 2026-11-06 15:46 — List the two send choices
- Intent: Tell the user the workable ways to get a phone text into WhatsApp.
- Changed: `docs/change-ledger.md` records the choices. No application code changed.
- Findings: The current Android app can open WhatsApp with a chosen text, and the user taps Send. Automatic delivery requires putting a WhatsApp API back. iPhone still cannot read Messages.
- Behavior: none.
- Business rules: none. BR-023 and BR-024 still apply.
- Verification: not run (docs only).
- Commit: `docs(agent): list the two send choices`

## 2026-11-06 15:45 — Explain automatic send needs an API
- Intent: Answer whether automatic WhatsApp sending requires a WhatsApp API.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: Sending without the WhatsApp Send tap requires a WhatsApp API. Opening the phone's WhatsApp app with the text filled in does not. The API path was removed with Twilio.
- Behavior: none.
- Business rules: none. BR-023 still applies.
- Verification: not run (docs only).
- Commit: `docs(android): explain automatic send needs an API`

## 2026-11-06 15:05 — Record the requested self-send
- Intent: The user wants every SMS read from the phone's Messages app and sent automatically to their own WhatsApp number.
- Changed: `docs/change-ledger.md` records the request. No application code changed.
- Findings: Android can read the stored texts and open WhatsApp addressed to the user's own number with a text filled in. The WhatsApp app on the phone still requires Send. Message Bridge cannot place those texts into the user's own WhatsApp chat by itself.
- Behavior: none.
- Business rules: none. BR-023 still applies.
- Verification: not run (docs only).
- Commit: `docs(android): record requested automatic self-send`

## 2026-11-06 15:02 — Explain Android still needs Send
- Intent: Answer whether Android can send the chosen text automatically.
- Changed: `docs/change-ledger.md` records the answer. No application code changed.
- Findings: The Android app lists stored texts and opens WhatsApp with the chosen text filled in. WhatsApp still requires the person to tap Send. The phone's own WhatsApp has no API that lets Message Bridge complete that send.
- Behavior: none.
- Business rules: none. BR-023 still applies.
- Verification: not run (docs only).
- Commit: `docs(android): explain Send stays in WhatsApp`

## 2026-11-05 18:43 — Check Message Bridge on the phone
- Intent: Confirm Message Bridge is installed on the connected Android phone.
- Changed: Replaced the phone's copy with today's debug build and opened it. `docs/change-ledger.md` records the check.
- Findings: The itel A667L had the app. A release APK from November 4 was installed first, then replaced with today's debug APK. `READ_SMS` is present and not granted. No message contents were read.
- Behavior: The current build is open on the phone. SMS access still needs the on-screen allow action.
- Business rules: none. BR-023 applies when SMS access is allowed.
- Verification: `adb dumpsys package` showed `com.actserv.message_bridge` version `1.0.0`. `adb install -r` of `app-debug.apk` succeeded. `am start` launched `MainActivity`.
- Commit: `docs(android): check the installed phone app`

## 2026-11-05 18:28 — Push main to GitHub
- Intent: Publish the current main branch before the Android phone test.
- Changed: `docs/change-ledger.md` records the push. No application code changed.
- Behavior: none.
- Business rules: none.
- Verification: `git status` showed a clean tree, `main` ahead of `origin/main` by 6 commits before this entry. `git push origin main` updated `6c7a96e..c24d4d8`. No secret values were in the unpushed diff.
- Commit: `docs(agent): push main to GitHub`

## 2026-11-05 18:25 — Ask to connect the Android phone
- Intent: Confirm that the SMS-to-WhatsApp flow should be tested on a connected Android phone.
- Changed: `docs/change-ledger.md` records this check. No application code changed.
- Findings: `flutter devices` showed macOS and Chrome only. No Android phone was connected.
- Behavior: none.
- Business rules: none. BR-023 is what the phone test would exercise.
- Verification: `flutter devices` completed and listed no Android device.
- Commit: `docs(android): ask to connect the phone`

## 2026-11-05 18:24 — Explain the next step
- Intent: Tell the user how to use the working Android flow and what remains on iPhone.
- Changed: `docs/change-ledger.md` records this guidance. No application code changed.
- Behavior: none.
- Business rules: none. BR-023 and BR-024 still apply.
- Verification: not run (docs only).
- Commit: `docs(agent): explain the next step`

## 2026-11-05 18:06 — Recheck iOS message access
- Intent: Find a supported way for the iPhone app to read existing Messages and open them in WhatsApp.
- Changed: `docs/change-ledger.md` records the check. No application code changed.
- Findings:
  - A normal iOS app still cannot read the Messages inbox or be notified when a text arrives.
  - Shortcuts can pass a new matching text into an action the user creates. It cannot read texts already stored in Messages.
  - TelephonyMessagingKit can receive new carrier texts only when Apple grants the default-carrier entitlement and the person in the EU selects that app. It does not read the existing Messages inbox.
- Behavior: none.
- Business rules: none. BR-024 still applies.
- Verification: not run (docs only).
- Commit: `docs(ios): recheck Messages inbox access`

## 2026-11-05 18:03 — Read Android texts; iOS inbox stays blocked
- Intent: List the phone's own texts and open a chosen one in WhatsApp, on Android and iOS.
- Changed: Android requests SMS read permission, lists up to 200 stored received and sent texts, and opens the chosen text in WhatsApp on the same phone.
- Changed: `lib/sms_inbox_page.dart`, `lib/compose_page.dart`, `lib/main.dart`, `MainActivity.kt`, `AndroidManifest.xml`, `test/sms_inbox_test.dart`, `README.md`.
- Changed: iOS stays on paste and type. Apple does not let a normal app read the Messages inbox.
- Behavior: Android shows the phone's texts and hands a chosen one to WhatsApp for the user to send. iOS does not list Messages.
- Business rules: BR-022 superseded by BR-023 and BR-024. BR-025 added. BR-024 kept after the iOS request.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (4 tests). `flutter build apk --debug` built `app-debug.apk`.
- Commit: `feat(android): read phone texts into WhatsApp`

## 2026-11-05 17:47 — Remove automatic Twilio forwarding
- Intent: Keep only the manual message composer and drop Twilio SMS forwarding.
- Changed: `lib/main.dart` always opens the composer. `lib/automation_page.dart` and `test/automation_test.dart` removed.
- Changed: Android SMS receiver, forwarding worker, encrypted store, method channel, SMS permissions, and WorkManager dependency removed. Next launch clears any stored forwarding data and its keystore key.
- Changed: `AndroidManifest.xml` declares the WhatsApp view intent. `ios/Runner/Info.plist` declares the WhatsApp URL scheme.
- Changed: `README.md` and `docs/business-rules.md` describe the composer-only app. Local `AGENTS.md` updated to match; it stays untracked.
- Behavior: Android and iOS show one composer that opens WhatsApp. The app no longer receives SMS or calls Twilio.
- Business rules: BR-003 and BR-021 superseded by BR-022. BR-001, BR-002, and BR-004 through BR-020 retired.
- Verification: `flutter analyze` reported no issues. `flutter test` passed (2 tests). `flutter build apk --debug` built `app-debug.apk`.
- Commit: `feat(ui): remove automatic Twilio forwarding`

## 2026-11-05 17:33 — Confirm project understanding
- Intent: Answer whether the current project structure and product rules are understood.
- Changed: `docs/change-ledger.md` records this read-only review.
- Behavior: none.
- Business rules: none. Review covered BR-001 through BR-021.
- Verification: not run (docs only). No application code changed.
- Commit: `docs(agent): confirm project understanding`

## 2026-11-04 22:53 — Rename agent-ignore commit

- Intent: Apply the user's exact requested message to the latest commit.
- Changed: `docs/change-ledger.md` records the corrected commit subject for
  the preceding agent-ignore change.
- Changed: Latest commit amended under the user's explicit rename request,
  overriding the normal no-amend and message-format rules for this operation.
  Remote update uses a lease pinned to the verified previous main tip.
- Behavior: none.
- Business rules: none.
- Verification: Working tree initially clean; local and remote main matched.
  Build not run (docs only). No application code changed.
- Commit: `feat:add files for both android and ios`

## 2026-11-04 22:52 — Keep agent instructions local

- Intent: Ignore the agent instructions file as requested.
- Changed: `.gitignore` excludes `AGENTS.md` and `agent.md`.
- Changed: `AGENTS.md` removed from the Git index; its local copy is preserved.
- Changed: `docs/change-ledger.md` records the repository-only change.
- Behavior: none.
- Business rules: none.
- Verification: `git check-ignore` matched both filenames; `test -f AGENTS.md`
  confirmed the local copy remains; `git diff --check` passed. Build not run
  (docs/config only). Staged paths inspected before committing.
- Commit: `chore(agent): keep agent instructions local`

## 2026-11-04 22:46 — Rename latest published commit

- Intent: Apply the user's exact requested commit message to the latest commit.
- Changed: `docs/change-ledger.md` records this correction; the previous entry's
  recorded commit subject is superseded by the subject below.
- Changed: Latest commit amended under the user's explicit rename request,
  which overrides the normal no-amend and commit-message-format rules for this
  operation. Remote update uses a lease pinned to the verified previous tip.
- Behavior: none.
- Business rules: none.
- Verification: Initial working tree clean; local and remote main tips matched.
  Build not run (docs only). No application source changed.
- Commit: `feat:add files for both android and ios`

## 2026-11-04 22:40 — Prepare project for GitHub push

- Intent: Publish the existing project and commit history to the user-specified
  GitHub repository on main.
- Changed: `.gitignore` now excludes all environment files and keystores.
- Changed: Git origin configured for the user-specified Message Bridge repository.
- Changed: `docs/change-ledger.md` records this publishing preparation.
- Behavior: none.
- Business rules: none; BR-005 and BR-006 guided credential exclusion checks.
- Verification: `git ls-remote` succeeded with no remote refs; working tree was
  initially clean; tracked-path and history pattern checks found no credential
  matches or tracked secret/configuration paths. `git check-ignore` confirmed
  local settings, environment files, signing keys, and generated directories
  are excluded. `git diff --check` passed. Build not run (docs/config only).
- Commit: `chore(agent): prepare project for GitHub push`

## 2026-11-04 14:43 — Diagnose no forwarding after enabling

- Intent: Explain why enabling automatic forwarding produced no visible result.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The app forwards only new incoming SMS after enabling; it never reads the
    SMS inbox history, so existing messages are not forwarded.
  - The app does not post a notification. The status card below the switch is
    the in-app indicator, and Twilio's logs or the recipient's WhatsApp show
    whether delivery happened.
  - The status remains "No SMS processed yet." until a new SMS arrives. If it
    does not change after a new plain SMS, check for RCS rather than SMS, an
    active sender filter, a force-stopped app, itel battery/autostart
    restrictions, or a rotated auth token that was not updated in the app.
  - Twilio errors: 20003 means bad SID/token; 63015 means the recipient has not
    joined the Sandbox; 63016 means the 24-hour session expired.
- Behavior: `none`.
- Business rules: `none`; BR-011 (no inbox history) and BR-002 (background
  forwarding) apply.
- Verification: confirmed the app process is running, `RECEIVE_SMS` is granted,
  the receiver is exported and registered, and no WorkManager job was queued.
  No credentials were accessed.
- Commit: `docs(agent): diagnose no forwarding after enable`



- Intent: Respond to the pasted Account SID and auth token.
- Changed: `docs/change-ledger.md` (this entry only); no credentials were
  stored and no source changed.
- Findings:
  - The first value is the Twilio Account SID. The second value matches the
    Auth Token format and is a secret.
  - The token was exposed in chat, so it must be considered compromised.
    Rotate or regenerate it in the Twilio Console's Account Info, then enter the
    new token on the phone.
  - Review Monitor logs and API keys for unexpected activity, enable two-factor
    authentication, and revoke the SendGrid key that was exposed earlier.
  - No Twilio API requests were made with the exposed credentials.
- Behavior: `none`.
- Business rules: `none` changed; BR-005 already requires credentials to stay
  off chat, logs, and ledgers.
- Verification: no credential values were written to files or used in commands.
- Commit: `docs(agent): flag exposed Twilio auth token`



- Intent: Confirm that the pasted value is the Twilio Account SID.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The value matches the Account SID shown on the Twilio account-selection
    page and has the expected `AC` plus 32 hexadecimal characters format.
  - The Auth Token is not shown on that page. Open the account, then use
    Account Dashboard → Account Info (or Admin → Account Info) to reveal and
    copy it. The Auth Token is the secret; it must not be shared in chat.
  - The WhatsApp Sandbox sender and join code are under
    Messaging → Try it out → Send a WhatsApp message.
  - Enter the SID, token, sender, and recipient on the phone in the Automatic
    tab.
- Behavior: `none`.
- Business rules: `none`.
- Verification: reviewed the Twilio account screenshot; no account access or
  credentials were used.
- Commit: `docs(agent): confirm Twilio Account SID format`



- Intent: Guide the user to the correct Twilio Console pages for the app's
  credentials and WhatsApp sender.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The Account SID and auth token are under the Account Dashboard's
    **Account Info** section, or the top-right **Admin** menu's account settings.
    The Account SID starts with `AC`.
  - The WhatsApp Sandbox is under **Messaging → Try it out → Send a WhatsApp
    message**; that page shows the sandbox sender number and the join code. The
    top **Jump to...** search can locate WhatsApp if the menu differs.
  - The Email section and SendGrid are unrelated to this WhatsApp flow. The
    trial balance is sufficient for sandbox testing.
  - Credentials must be entered on the phone, never in chat or the ledgers.
- Behavior: `none`.
- Business rules: `none`.
- Verification: reviewed the Twilio Console screenshot; no account access or
  credentials were used.
- Commit: `docs(agent): locate Twilio SID and WhatsApp Sandbox in Console`



- Intent: Answer whether the pasted value is a Twilio Account SID.
- Changed: `docs/change-ledger.md` (this entry only); no source changes and the
  value was not written to any file.
- Findings:
  - The pasted value is a SendGrid API key (`SG.` prefix), not a Twilio Account
    SID. Twilio Account SIDs start with `AC` followed by 32 hexadecimal
    characters.
  - SendGrid is an email API; its key cannot authenticate Twilio's WhatsApp API.
    Twilio's ownership of SendGrid does not make the credentials interchangeable.
  - The value was exposed in chat and should be revoked or rotated in SendGrid.
    A project-file search for `SENDGRID_API_KEY` found no matches, including in
    tracked content.
  - Twilio credentials come from `console.twilio.com` and must be entered only
    on the phone.
- Behavior: `none`.
- Business rules: `none`; BR-005 already requires credentials to stay off
  ledgers, commits, and chat.
- Verification: searched the workspace for `SENDGRID_API_KEY`; no files
  contained it.
- Commit: `docs(agent): clarify SendGrid key vs Twilio SID`



- Intent: Explain why the Automatic forwarding switch is grayed out.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The switch is disabled while a request is running or when no saved
    connection exists. It becomes active only after **Save connection** succeeds
    with a valid Account SID, token, WhatsApp sender, and destination number.
  - `_saved` starts from the stored `hasToken` value and is cleared whenever any
    field is edited, so editing the configuration requires saving it again
    before enabling forwarding.
  - Validation requires an `AC` Account SID, a non-empty token (or a previously
    saved one), and international sender/recipient numbers with a leading `+`
    and no `whatsapp:` prefix.
- Behavior: `none`.
- Business rules: `none`.
- Verification: reviewed `lib/automation_page.dart`; no commands were needed.
- Commit: `docs(agent): explain disabled automatic forwarding switch`



- Intent: Give the user the steps to test automatic forwarding with the Twilio
  Account SID and auth token they already have.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The app is running on the itel A667L and `RECEIVE_SMS` is granted.
  - The Automatic tab needs the Account SID, auth token, WhatsApp sender, and
    destination number. The sender must be the WhatsApp Sandbox sender shown in
    the Twilio Console, and the destination must first join that sandbox to open
    a 24-hour session.
  - Credentials stay on the phone; they must not be written to chat or ledgers.
- Behavior: `none`.
- Business rules: `none`.
- Verification: confirmed the app process, foreground activity, and SMS
  permission with `adb`.
- Commit: `docs(agent): guide Twilio SMS forwarding test`



- Intent: Answer whether the user's SendGrid account can be linked and which
  Twilio API the app uses.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - SendGrid is an email API. Twilio owns SendGrid, but the products and
    credentials are separate, so SendGrid keys cannot authenticate WhatsApp.
  - The Android worker calls Twilio Programmable Messaging at
    `/2010-04-01/Accounts/{AccountSid}/Messages.json` with `From`/`To` values
    prefixed by `whatsapp:` and Basic authentication using the Account SID and
    auth token.
  - No Twilio account is configured in the app yet. The app expects the details
    shown in the Twilio Console's WhatsApp Sandbox, and the recipient must join
    that sandbox first.
  - Credentials must be entered on the phone, never in chat or the ledgers.
- Behavior: `none`.
- Business rules: `none`.
- Verification: reviewed `ForwardSmsWorker.kt` and the README Twilio references;
  no commands were needed.
- Commit: `docs(agent): clarify Twilio and SendGrid`



- Intent: Give Android users a message textarea instead of exposing only the
  Twilio SMS setup.
- Changed:
  - `lib/main.dart` — added `AndroidHome` with Message and Automatic tabs. The
    app opens on Message; removed the unwired `message_bridge/sms` import switch
    from the composer.
  - `test/automation_test.dart` — updated tests to open the Automatic tab and
    assert that the composer is the default.
  - `docs/business-rules.md` — added BR-021 for the Android manual composer.
  - `README.md` — documented the Message and Automatic tabs.
- Behavior: Android now opens on a composer where the user can type or paste a
  message, optionally enter a recipient, and continue in WhatsApp. The user
  still taps Send in WhatsApp. Automatic SMS forwarding remains on the
  Automatic tab.
- Business rules: `BR-021` added.
- Verification: `dart format`; `flutter analyze` found no issues; `flutter test`
  passed all 4 tests; the 13.3 MB arm Release APK built, installed, and launched
  on the itel A667L. A screenshot confirmed the textarea and bottom tabs, with
  no ANR or fatal crash.
- Commit: `feat(ui): add Android message composer tab`



- Intent: Explain why the Android UI asks for Twilio credentials and which
  messages the app can read.
- Changed: `docs/change-ledger.md` (this entry only); no source changes.
- Findings:
  - The Android page is the forwarding setup screen; it does not compose or
    display messages.
  - Sending uses Twilio's WhatsApp API, so the Account SID, auth token, sender,
    and recipient are required. The app does not send through the phone's
    personal WhatsApp.
  - The app reads incoming SMS only (`RECEIVE_SMS`) directly from the broadcast,
    so there is no copy step. It cannot read WhatsApp chats, notifications, or
    other apps' messages.
  - Silent sending from a personal WhatsApp account is not supported by WhatsApp;
    automatic delivery requires the WhatsApp Business API/Twilio.
  - The manual compose screen exists only on iOS. Adding one to Android would
    still require the user to tap Send in WhatsApp.
  - Reading other apps' notifications would be a separate
    `NotificationListenerService` feature and is not implemented.
- Behavior: `none`.
- Business rules: `none`.
- Verification: reviewed `lib/main.dart`, `lib/automation_page.dart`, and the
  Android receiver/worker; no commands were needed.
- Commit: `docs(agent): clarify Android message source and Twilio tokens`



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
