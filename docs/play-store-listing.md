# Play Store listing copy — Message Bridge

Use **Grow users → Store presence → Main store listing** (English en-US).

## Short description (max 80 chars)

```
Treasurer: paste M-Pesa SMS, track group totals, share updates on WhatsApp.
```

## Full description (max 4000 chars)

```
Message Bridge helps WhatsApp group treasurers track M-Pesa contributions.

Copy each M-Pesa “received” SMS from your Messages app and paste it in the app. We extract the payer’s name and amount, keep a running total, and draft text for your group or a thank-you message. You choose the WhatsApp chat and tap Send.

• Paste M-Pesa SMS only — we do not read your SMS inbox (no SMS permission)
• First name, surname, amount, optional phone from the pasted text
• Running total and copyable group update
• Opens WhatsApp with your message prefilled
• No ads, no account, no cloud upload, no Twilio

You run the fundraiser; the app does not move money or post to WhatsApp for you automatically.

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

1. Upload production bundle **7 (1.0.0)** or higher (treasurer + no `READ_SMS`).
2. **App content** → withdraw SMS/call-log declaration if still present.
3. **Publishing overview** → **Send app for review**