-- PicklePoint database schema for Supabase
-- Run this entire file in Supabase SQL Editor.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text,
  role text not null default 'customer' check (role in ('admin','customer')),
  created_at timestamptz not null default now()
);

create table if not exists public.courts (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  type text not null default 'Indoor',
  hourly_rate numeric(10,2) not null default 350 check (hourly_rate >= 0),
  status text not null default 'available' check (status in ('available','maintenance')),
  created_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  court_id uuid not null references public.courts(id) on delete restrict,
  booking_date date not null,
  start_time time not null,
  duration_minutes integer not null default 60 check (duration_minutes > 0),
  total_amount numeric(10,2) not null check (total_amount >= 0),
  payment_method text not null check (payment_method in ('GCash','Cash')),
  payment_reference text,
  payment_status text not null default 'pending' check (payment_status in ('pending','for_verification','paid','rejected')),
  status text not null default 'confirmed' check (status in ('confirmed','completed','cancelled')),
  created_at timestamptz not null default now(),
  unique(court_id, booking_date, start_time)
);

-- Automatically create a profile after Supabase Auth registration.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'New Player'),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.courts enable row level security;
alter table public.bookings enable row level security;

-- Helper function for role checks.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- Profiles: users can read their own profile; admins can read all.
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles
for select using (id = auth.uid() or public.is_admin());

-- Courts: public read; admins manage.
drop policy if exists "courts_public_read" on public.courts;
create policy "courts_public_read" on public.courts for select using (true);
drop policy if exists "courts_admin_insert" on public.courts;
create policy "courts_admin_insert" on public.courts for insert with check (public.is_admin());
drop policy if exists "courts_admin_update" on public.courts;
create policy "courts_admin_update" on public.courts for update using (public.is_admin()) with check (public.is_admin());
drop policy if exists "courts_admin_delete" on public.courts;
create policy "courts_admin_delete" on public.courts for delete using (public.is_admin());

-- Bookings: customers can see/create/update/delete their own; admins can manage all.
drop policy if exists "bookings_select_own_or_admin" on public.bookings;
create policy "bookings_select_own_or_admin" on public.bookings
for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "bookings_insert_own_or_admin" on public.bookings;
create policy "bookings_insert_own_or_admin" on public.bookings
for insert with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "bookings_update_own_or_admin" on public.bookings;
create policy "bookings_update_own_or_admin" on public.bookings
for update using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "bookings_delete_own_or_admin" on public.bookings;
create policy "bookings_delete_own_or_admin" on public.bookings
for delete using (user_id = auth.uid() or public.is_admin());

-- Seed courts.
insert into public.courts (name,type,hourly_rate,status) values
('Court 1','Indoor',350,'available'),
('Court 2','Indoor',350,'available'),
('Court 3','Outdoor',300,'available')
on conflict (name) do nothing;

-- IMPORTANT:
-- After registering your own account, make yourself admin with:
-- update public.profiles set role='admin' where email='YOUR_EMAIL_HERE';
