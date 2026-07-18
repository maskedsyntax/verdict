# Supabase Phase 2

The app remains fully playable without Supabase. When configured, Phase 2 adds
anonymous authentication, public usernames, validated score submission, and the
Classic top-10 leaderboard.

## Deploy

1. Create or link a Supabase project.
2. Enable anonymous sign-ins under Authentication settings.
3. Apply `supabase/migrations` with `supabase db push`.
4. Never expose or bundle the service-role key.

The seed migration is generated from the same committed word schedule used by
the app:

```sh
dart run tool/generate_supabase_seed.dart supabase/migrations/202607190002_word_seed.sql
```

Run a configured build with the public project values:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Legacy `SUPABASE_ANON_KEY` builds are accepted as a fallback. Configuration is
supplied through local commands or CI secrets and is never committed.

## Security Boundary

- Clients cannot read puzzle answers or the server dictionary.
- Clients cannot insert or update raw scores.
- `submit_daily_score` validates authentication, username, date, puzzle, guess
  count, dictionary membership, and the solved answer before calculating score.
- One score is accepted per authenticated user and daily puzzle.
- `get_leaderboard` returns only public usernames and aggregated scores.

The bundled answer list is necessarily inspectable in an offline word game, so
this is baseline anti-spoofing rather than tamper-proof competitive security.
