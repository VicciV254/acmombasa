-- American Corner Mombasa: cloud tables for terminal sync.
-- Run this once in the Supabase dashboard: SQL Editor -> New query -> Run.
--
-- Security model
--   * The desktop app only ever uses the public anon key plus a signed-in
--     Supabase user. The service-role key is never used by the app.
--   * Row-level security is ON for every table; only authenticated users can
--     read or write. Create one Supabase Auth user for the terminals to sync
--     with (Authentication -> Users -> Add user) and sign in with it from the
--     app's "Cloud sync" dialog.

create table if not exists public.visitors (
  id            text primary key,
  member_id     text not null,
  full_name     text not null,
  phone         text not null,
  email         text,
  category      text not null default 'General Visitor',
  is_verified   boolean not null default true,
  card_issued   boolean not null default false,
  registered_at timestamptz not null,
  updated_at    timestamptz not null
);

create table if not exists public.programs (
  id           text primary key,
  name         text not null,
  location     text not null,
  start_minute integer,
  end_minute   integer,
  note         text,
  is_active    boolean not null default true,
  sort_order   integer not null default 0,
  updated_at   timestamptz not null
);

create table if not exists public.visits (
  id           text primary key,
  visitor_id   text not null,
  program_id   text,
  purpose      text not null,
  workstation  text,
  check_in_at  timestamptz not null,
  check_out_at timestamptz,
  staff_id     text not null,
  updated_at   timestamptz not null
);

-- The app pulls by "updated_at > cursor", so index it.
create index if not exists visitors_updated_at_idx on public.visitors (updated_at);
create index if not exists programs_updated_at_idx on public.programs (updated_at);
create index if not exists visits_updated_at_idx   on public.visits   (updated_at);
create index if not exists visits_visitor_idx      on public.visits   (visitor_id);

alter table public.visitors enable row level security;
alter table public.programs enable row level security;
alter table public.visits   enable row level security;

do $$
declare t text;
begin
  foreach t in array array['visitors', 'programs', 'visits'] loop
    execute format('drop policy if exists "authenticated full access" on public.%I', t);
    execute format(
      'create policy "authenticated full access" on public.%I
         for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;
