# Habit Tracker

Daily habit tracking. Guest data stays on the device. Signed-in data is stored per user in Supabase.

Flutter **3.47.2** (see [`.tool-versions`](.tool-versions)). Android application ID: `io.github.danny270793.timetracker`. iOS bundle ID: `io.github.danny270793.timetracker`.

## Quick start

```sh
cp .env.example.json .env.json   # then fill in real values
asdf exec flutter pub get
asdf exec flutter gen-l10n
asdf exec flutter run --dart-define-from-file=.env.json
```

## Documentation

- [Run on an emulator or device](docs/getting-started.md)
- [Fill `.env.json`](docs/environment.md)
- [Sync Xcode and publish to the App Store](docs/app-store.md)
- [Bump app version and Flutter SDK](docs/versioning.md)
- [Supabase schema](https://github.com/danny270793/supabase): the `habit_tracker_data` table lives in the shared danny270793/supabase repo

## Database

Habit Tracker shares one Supabase project with Wallet, Family Games, and Hangman. Table `habit_tracker_data` stores one JSON document per `auth.users` id (`habits` jsonb). Guests use local storage only; after sign-in, guest habits merge into the cloud row.

Migrations live in [danny270793/supabase](https://github.com/danny270793/supabase). Create and apply them there, not in this repo. Do not add the service role key to the Flutter app.

## Agents

See [AGENTS.md](AGENTS.md) (Claude: [CLAUDE.md](CLAUDE.md)).
