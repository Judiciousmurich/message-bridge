# Play Store listing copy — Message Bridge

Use **Grow users → Store presence → Main store listing** (English en-US).

## Short description (max 80 chars)

```
Copy a text, open WhatsApp with it prefilled. No SMS read, no cloud upload.
```

## Full description (max 4000 chars)

```
Message Bridge helps you move text into WhatsApp Messenger quickly.

Copy a message from your Messages app (or type it), save your WhatsApp number once, and tap Continue in WhatsApp. WhatsApp opens with your text ready—you tap Send.

• Does not read your SMS inbox — no sensitive SMS permission
• Opens WhatsApp with your message prefilled
• No ads, no account login, no Twilio
• Same paste/type flow on Android and iPhone

Message Bridge does not send SMS for you and is not a replacement for your Messages or WhatsApp apps. WhatsApp must be installed on Android.

Privacy policy: https://cdn.jsdelivr.net/gh/Judiciousmurich/message-bridge@main/docs/privacy-policy.html

Data deletion: https://cdn.jsdelivr.net/gh/Judiciousmurich/message-bridge@main/docs/data-deletion.html
```

## Graphics (upload from repo or Desktop)

| Asset | File |
|--------|------|
| App icon 512×512 | `docs/play-store-assets/icon-512.png` |
| Feature graphic 1024×500 | `docs/play-store-assets/feature-graphic.jpg` |
| Phone screenshots (≥2) | `docs/play-store-assets/play-screenshot-1.jpg`, `play-screenshot-2.jpg` |

Desktop copies: folder `Message-Bridge-Play-assets` (if created) or files in `docs/play-store-assets/`.

## After listing is saved

1. Upload production bundle **5 (1.0.0)** or higher (no `READ_SMS`).
2. **App content** → withdraw SMS/call-log declaration if still present.
3. **Publishing overview** → **Send app for review**