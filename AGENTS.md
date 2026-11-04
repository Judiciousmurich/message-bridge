# AGENTS.md

Operating instructions for AI agents working in this repository.

## Project

Message Bridge (`message_bridge`) is a Flutter app. On Android it forwards new
incoming SMS to a WhatsApp recipient through Twilio's WhatsApp API. iOS keeps
the manual compose flow. The partial Expo starter in `.previous-expo/` is
legacy and unused.

Key paths:

- `lib/main.dart`, `lib/automation_page.dart` — Flutter UI.
- `android/app/src/main/kotlin/com/actserv/message_bridge/` — Android SMS
  receiver, forwarding worker, encrypted store, and method channel.
- `android/app/src/main/AndroidManifest.xml` — permissions, receiver, and
  backup settings.
- `README.md` — setup, test procedure, and operational notes.
- `docs/change-ledger.md` — what changed on each turn.
- `docs/business-rules.md` — what the product must keep doing.

## Mandatory turn protocol

Every turn is a unit of work with a traceable record. This includes read-only
turns, investigations, and documentation-only edits.

At the start of a turn:

1. Read `docs/change-ledger.md` (newest entries first).
2. Read `docs/business-rules.md` and note the rule IDs relevant to the task.

At the end of a turn, in this order:

1. Verify the work (see Verification).
2. Append one entry to `docs/change-ledger.md`.
3. If the turn changed business behavior, update `docs/business-rules.md` and
   reference the affected rule IDs in the ledger entry.
4. Commit everything, including both ledgers, so the working tree is clean.
5. Report the commit hash and a one-line outcome in the final response.

Hard rules:

- Never end a turn with uncommitted or untracked changes.
- The ledger entry guarantees there is always something to commit, even when
  no code changed.
- Never rewrite history (`git commit --amend`, rebase, `git reset --hard`) or
  force-push. Both ledgers are append-only; correct mistakes with a new entry.
- Never mark verification as passed unless the command actually ran and passed.
- Never put credentials, tokens, real phone numbers, or SMS contents in the
  ledgers, commit messages, or chat.

## Verification

Run the cheapest checks that cover the change before committing:

- Any Dart change: `flutter analyze` and `flutter test`.
- Android native change: `flutter analyze`, plus `flutter build apk --debug`
  when the Android SDK is available. If a check cannot run in this environment,
  record that fact and why in the ledger.
- Documentation-only change: no build required; record `not run (docs only)`.

If a check fails:

- Fix it in the same turn when possible.
- If it cannot be fixed, commit with a `wip:` prefix, describe the failure in
  the ledger and the final response, and do not claim success.
- Distinguish pre-existing failures from failures introduced by the turn.

## Change ledger

`docs/change-ledger.md` is the chronological, append-only record of agent work.
Add new entries at the top, one entry per turn. Keep entries factual and short.

Template:

```markdown
## YYYY-MM-DD HH:MM — short title
- Intent: why the turn happened.
- Changed: files or systems touched, one line each.
- Behavior: user-visible effect, or `none`.
- Business rules: `none`, or `BR-### [added|updated|superseded|retired]`.
- Verification: commands run and their actual result.
- Commit: the commit subject used for this turn.
```

Do not put secrets, real phone numbers, tokens, or SMS contents in an entry.
Do not amend a commit just to add its hash; the hash is reported in the final
response instead.

## Business rules ledger

`docs/business-rules.md` records externally observable product behavior and
constraints. It is the source of truth: if code, tests, or `README.md`
contradicts it, stop and surface the conflict instead of silently choosing one.

Update this ledger only when behavior intentionally changes. Pure refactors,
formatting, and test-only changes do not change business rules.

When a rule changes:

- Keep its stable ID. Never renumber or reuse an ID.
- Never delete an active rule. Mark it `Superseded` and add its replacement with
  the next free ID, or mark it `Retired` if it no longer applies.
- Add a `History` line with the date and reason.
- Reference the rule IDs in the change ledger entry.

If no rule changed, write `Business rules: none` in the change ledger entry.

## Commits

Every turn ends in at least one commit.

Message format:

```text
<type>(<scope>): <summary>

<body: what changed and why, one to three sentences>

Ledger: YYYY-MM-DD HH:MM — <same title as the ledger entry>
```

- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `wip`.
- Scopes: `android`, `ios`, `ui`, `rules`, `agent`, `deps`.

Before committing:

- Run `git status --short` and inspect every path; stage only intended files.
- Confirm no secrets or local configuration are staged, including
  `android/local.properties`, `android/key.properties`, `*.jks`, `*.keystore`,
  `.env*`, tokens, and real phone numbers. Fix `.gitignore` instead of
  committing them.
- Never commit `build/`, `.dart_tool/`, `node_modules/`, or `.previous-expo/`;
  they are ignored and must stay untouched.

## Change discipline

- Keep the diff scoped to the request. Do not refactor unrelated code.
- Preserve existing product behavior unless the request explicitly changes it.
- `.previous-expo/` is a preserved legacy starter; do not modify or revive it.
- Never log or display the Twilio auth token or SMS bodies.
- Do not add dependencies, analytics, or network endpoints without stating why
  in the change ledger entry.
- Do not edit generated files: `build/`, `.dart_tool/`, `node_modules/`,
  `android/.gradle/`, `.idea/`, or `*.iml`.

## End-of-turn checklist

- [ ] Both ledgers read before starting.
- [ ] Relevant business rules identified.
- [ ] Changes implemented and scoped.
- [ ] Verification run and results recorded honestly.
- [ ] Change ledger entry appended (newest first).
- [ ] Business rules ledger updated, or the entry says `none`.
- [ ] All changes committed using the commit format above.
- [ ] `git status --short` is empty.
