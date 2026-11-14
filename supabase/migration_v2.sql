-- American Corner Mombasa: schema v2 (programs roster + reports).
-- Run once in the Supabase SQL Editor AFTER schema.sql. Safe to re-run.

alter table public.visitors add column if not exists gender     text;
alter table public.visitors add column if not exists age_bracket text;
alter table public.visitors add column if not exists residence  text;
alter table public.visitors add column if not exists occupation text;

alter table public.programs add column if not exists session_date     timestamptz;
alter table public.programs add column if not exists recurrence       text    not null default 'daily';
alter table public.programs add column if not exists pillar           text    not null default 'General Programs';
alter table public.programs add column if not exists format           text    not null default 'in_person';
alter table public.programs add column if not exists capacity         integer;
alter table public.programs add column if not exists facilitator      text;
alter table public.programs add column if not exists walk_ins_allowed boolean not null default true;
alter table public.programs add column if not exists audience         text;
alter table public.programs add column if not exists status           text    not null default 'published';

create table if not exists public.program_registrations (
  id          text primary key,
  program_id  text not null,
  visitor_id  text not null,
  session_day timestamptz not null,
  created_at  timestamptz not null,
  updated_at  timestamptz not null
);
create index if not exists program_registrations_updated_at_idx
  on public.program_registrations (updated_at);

alter table public.program_registrations enable row level security;
drop policy if exists "authenticated full access" on public.program_registrations;
create policy "authenticated full access" on public.program_registrations
  for all to authenticated using (true) with check (true);
