-- QuoteNest cloud foundation: Supabase PostgreSQL
-- Review and apply in a development project before production.
create extension if not exists pgcrypto;

create table if not exists public.businesses (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null default 'My business', email text, phone text, address text,
 currency text not null default 'EUR' check(currency in ('EUR','GBP','USD')),
 default_tax_rate numeric(6,3) not null default 0 check(default_tax_rate between 0 and 100),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.business_members (
 business_id uuid not null references public.businesses(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null check(role in ('owner','admin','member','viewer')),
 created_at timestamptz not null default now(), primary key(business_id,user_id)
);
create table if not exists public.customers (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references public.businesses(id) on delete cascade,
 name text not null, email text, phone text, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(), unique(business_id,id)
);
create table if not exists public.services (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references public.businesses(id) on delete cascade,
 name text not null, category text not null default 'General', unit text not null default 'unit',
 unit_price numeric(12,2) not null default 0 check(unit_price>=0), created_at timestamptz not null default now()
);
create table if not exists public.quotes (
 id uuid primary key default gen_random_uuid(), business_id uuid not null references public.businesses(id) on delete cascade,
 customer_id uuid, title text not null,
 status text not null default 'Draft' check(status in ('Draft','Sent','Approved','Declined','Expired')),
 package text not null default 'Standard' check(package in ('Standard','Better','Best')),
 currency text not null default 'EUR' check(currency in ('EUR','GBP','USD')),
 tax_rate numeric(6,3) not null default 0 check(tax_rate between 0 and 100),
 subtotal numeric(12,2) not null default 0 check(subtotal>=0),
 tax_total numeric(12,2) not null default 0 check(tax_total>=0), total numeric(12,2) not null default 0 check(total>=0),
 customer_comment text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 constraint quotes_customer_same_business_fk foreign key(business_id,customer_id) references public.customers(business_id,id)
);
create table if not exists public.quote_items (
 id uuid primary key default gen_random_uuid(), quote_id uuid not null references public.quotes(id) on delete cascade,
 description text not null, quantity numeric(12,3) not null default 1 check(quantity>0),
 unit text not null default 'unit', unit_price numeric(12,2) not null default 0 check(unit_price>=0),
 line_total numeric(12,2) generated always as(round(quantity*unit_price,2)) stored
);
create table if not exists public.quote_public_links (
 id uuid primary key default gen_random_uuid(), quote_id uuid not null unique references public.quotes(id) on delete cascade,
 token_hash text not null unique, expires_at timestamptz not null, revoked_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.quote_events (
 id uuid primary key default gen_random_uuid(), quote_id uuid not null references public.quotes(id) on delete cascade,
 event_type text not null check(event_type in ('link_created','viewed','approved','declined')), created_at timestamptz not null default now()
);
create table if not exists public.subscriptions (
 id uuid primary key default gen_random_uuid(), business_id uuid not null unique references public.businesses(id) on delete cascade,
 provider_customer_id text, provider_subscription_id text unique,
 plan text not null default 'free' check(plan in ('free','pro','business')),
 status text not null default 'inactive' check(status in ('inactive','trialing','active','past_due','canceled')),
 current_period_end timestamptz, updated_at timestamptz not null default now()
);
create index if not exists idx_customers_business on public.customers(business_id);
create index if not exists idx_quotes_business_created on public.quotes(business_id,created_at desc);
create index if not exists idx_quote_items_quote on public.quote_items(quote_id);
create index if not exists idx_quote_events_quote on public.quote_events(quote_id,created_at desc);

create or replace function public.is_business_member(target_business uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.business_members m where m.business_id=target_business and m.user_id=auth.uid()) $$;
create or replace function public.is_business_admin(target_business uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.business_members m where m.business_id=target_business and m.user_id=auth.uid() and m.role in ('owner','admin')) $$;

alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.customers enable row level security;
alter table public.services enable row level security;
alter table public.quotes enable row level security;
alter table public.quote_items enable row level security;
alter table public.quote_public_links enable row level security;
alter table public.quote_events enable row level security;
alter table public.subscriptions enable row level security;

create policy "business members can read business" on public.businesses for select using(public.is_business_member(id) or owner_id=auth.uid());
create policy "owners can insert business" on public.businesses for insert with check(owner_id=auth.uid());
create policy "admins can update business" on public.businesses for update using(public.is_business_admin(id)) with check(public.is_business_admin(id));
create policy "admins can delete business" on public.businesses for delete using(public.is_business_admin(id));
create policy "members read memberships" on public.business_members for select using(public.is_business_member(business_id));
create policy "owners add initial membership" on public.business_members for insert
with check(user_id=auth.uid() and exists(select 1 from public.businesses b where b.id=business_id and b.owner_id=auth.uid()));
create policy "admins manage memberships" on public.business_members for update using(public.is_business_admin(business_id)) with check(public.is_business_admin(business_id));
create policy "admins remove memberships" on public.business_members for delete using(public.is_business_admin(business_id));
create policy "members manage customers" on public.customers for all using(public.is_business_member(business_id)) with check(public.is_business_member(business_id));
create policy "members manage services" on public.services for all using(public.is_business_member(business_id)) with check(public.is_business_member(business_id));
create policy "members manage quotes" on public.quotes for all using(public.is_business_member(business_id)) with check(public.is_business_member(business_id));
create policy "members manage quote items" on public.quote_items for all
using(exists(select 1 from public.quotes q where q.id=quote_id and public.is_business_member(q.business_id)))
with check(exists(select 1 from public.quotes q where q.id=quote_id and public.is_business_member(q.business_id)));
create policy "members read own public links" on public.quote_public_links for select
using(exists(select 1 from public.quotes q where q.id=quote_id and public.is_business_member(q.business_id)));
create policy "members read quote events" on public.quote_events for select
using(exists(select 1 from public.quotes q where q.id=quote_id and public.is_business_member(q.business_id)));
create policy "members read subscription" on public.subscriptions for select using(public.is_business_member(business_id));
create policy "admins create initial subscription" on public.subscriptions for insert with check(public.is_business_admin(business_id));

revoke all on public.quote_public_links from anon,authenticated;
revoke all on public.subscriptions from anon,authenticated;
grant select on public.subscriptions to authenticated;

-- Fields needed by the QuoteNest browser app's cloud sync.
alter table public.services add column if not exists estimated_cost numeric(12,2) not null default 0 check (estimated_cost >= 0);
alter table public.quotes add column if not exists quote_date date not null default current_date;
alter table public.quotes add column if not exists cost_total numeric(12,2) not null default 0 check (cost_total >= 0);
alter table public.quotes add column if not exists profit_total numeric(12,2) not null default 0;
alter table public.quotes add column if not exists internal_note text;
alter table public.quote_items add column if not exists unit_cost numeric(12,2) not null default 0 check (unit_cost >= 0);

-- Enable cross-device live refresh for the app's primary workspace tables.
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='customers') then alter publication supabase_realtime add table public.customers; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='services') then alter publication supabase_realtime add table public.services; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='quotes') then alter publication supabase_realtime add table public.quotes; end if;
end $$;
