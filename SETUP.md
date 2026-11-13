# American Corner Mombasa: setup

## 1. Packages

Run these once in your Flutter project folder:

```
flutter pub add flutter_riverpod:^2.6.1 drift drift_flutter crypto path_provider supabase_flutter pdf printing
flutter pub add --dev drift_dev build_runner
```

Windows plugins need **Developer Mode** switched on (Settings → System → For
developers) so Flutter can create symlinks.

## 2. Generate the database code

The database is declared in `lib/core/database/tables.dart`. Drift writes the
rest:

```
dart run build_runner build --delete-conflicting-outputs
```

Re-run it whenever `tables.dart` changes. If Windows later complains it cannot
find `sqlite3.dll`, add the `sqlite3_flutter_libs` package.

## 3. Supabase (cloud sync)

1. Create a project at supabase.com.
2. SQL Editor → paste `supabase/schema.sql` → Run.
3. Authentication → Users → **Add user** (tick *Auto Confirm User*). This single
   account is what the terminals use to sync; staff accounts stay local.
4. Project Settings → API: copy the **Project URL** and the **anon / public**
   key. Never copy or use the `service_role` key anywhere in this app.
5. Copy `env.example.json` to `env.json`, fill in the two values, and keep
   `env.json` out of Git.

## 4. Run

```
flutter run -d windows --dart-define-from-file=env.json
```

Without `env.json` the app still runs fully offline; the cloud pill in the top
bar shows "Cloud sync off".

## First launch

1. Create the administrator account (first run only).
2. Click **New** to register a visitor, then check them in.
3. Click the status pill in the top bar → sign in with the Supabase account
   from step 3 → **Sync now**.
4. Admins can add receptionists from the account menu (top right).
