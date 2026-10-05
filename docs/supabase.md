# Supabase (Habit Tracker)

This app shares the same Supabase project as Wallet. Schema lives in [`supabase/migrations`](../supabase/migrations).

## Habit data

Table `habit_tracker_data` stores one JSON document per `auth.users` id (`habits` jsonb). Guests use local storage only. After sign-in, guest habits are merged into the cloud row.

## Apply migrations

From this repo (after `supabase login` and `supabase link`):

```sh
supabase db push
```

Keep migration files in lockstep with Wallet, MMA Scorecard, and Boxing timer. Do not add the service role key to the Flutter app.
