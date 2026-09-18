-- =========================================================
-- KITCHEN CRAT PK — SUPABASE SCHEMA
-- Run this whole file in Supabase: Dashboard -> SQL Editor -> New query
-- =========================================================

-- 1) Products table -----------------------------------------------------
create table if not exists products (
  id          bigint generated always as identity primary key,
  name        text not null,
  slug        text,
  category    text not null default 'Cookware',
  description text default '',
  features    jsonb default '[]'::jsonb,       -- array of strings
  price       numeric not null default 0,
  old_price   numeric,
  discount    text default '',                  -- e.g. "30% OFF"
  image       text default '',                  -- main image URL
  images      jsonb default '[]'::jsonb,         -- extra image URLs
  rating      numeric default 4.5,
  reviews     integer default 0,
  stock       text default 'In Stock',           -- 'In Stock' / 'Out of Stock'
  badge       text default '',                   -- 'New' / 'Sale' / custom text
  featured    boolean default false,
  is_new      boolean default false,
  on_sale     boolean default false,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- 2) Orders table ---------------------------------------------------------
create table if not exists orders (
  id            bigint generated always as identity primary key,
  customer_name text not null,
  phone         text not null,
  whatsapp      text,
  address       text not null,
  city          text not null,
  items         jsonb not null,       -- [{id, name, price, qty}]
  subtotal      numeric not null,
  delivery      numeric default 0,
  total         numeric not null,
  status        text default 'New',  -- New / Confirmed / Processing / Shipped / Delivered / Cancelled
  notes         text default '',
  created_at    timestamptz default now()
);

-- 3) Store settings (single row) ------------------------------------------
create table if not exists store_settings (
  id               int primary key default 1,
  store_name       text default 'Kitchen Crat PK',
  whatsapp_number  text default '923XXXXXXXXX',
  contact_phone    text default '+92 300 0000000',
  contact_email    text default '',
  address          text default 'Lahore, Pakistan',
  delivery_info    text default 'Free delivery across Pakistan',
  social_links     jsonb default '{}'::jsonb,
  constraint single_row check (id = 1)
);
insert into store_settings (id) values (1) on conflict (id) do nothing;

-- 4) Admin allowlist --------------------------------------------------------
-- Add the exact email(s) that are allowed to manage the store.
-- IMPORTANT: edit this email to match the admin user you create in
-- Supabase Auth (see README "Setup Guide").
create table if not exists admin_users (
  email text primary key
);
insert into admin_users (email) values ('admin@kitchencratpk.com')
  on conflict (email) do nothing;

-- =========================================================
-- ROW LEVEL SECURITY
-- =========================================================
alter table products      enable row level security;
alter table orders        enable row level security;
alter table store_settings enable row level security;
alter table admin_users   enable row level security;

-- Helper: is the current logged-in user an admin?
create or replace function is_admin() returns boolean as $$
  select exists (
    select 1 from admin_users
    where email = (auth.jwt() ->> 'email')
  );
$$ language sql stable security definer;

-- Products: everyone can read; only admin can write
drop policy if exists "products_public_read" on products;
create policy "products_public_read" on products
  for select using (true);

drop policy if exists "products_admin_write" on products;
create policy "products_admin_write" on products
  for all using (is_admin()) with check (is_admin());

-- Orders: anyone (including anonymous shoppers) can INSERT an order,
-- but only admin can read or update the order list.
drop policy if exists "orders_public_insert" on orders;
create policy "orders_public_insert" on orders
  for insert with check (true);

drop policy if exists "orders_admin_read" on orders;
create policy "orders_admin_read" on orders
  for select using (is_admin());

drop policy if exists "orders_admin_update" on orders;
create policy "orders_admin_update" on orders
  for update using (is_admin()) with check (is_admin());

-- Store settings: everyone can read (footer/contact info), only admin writes
drop policy if exists "settings_public_read" on store_settings;
create policy "settings_public_read" on store_settings
  for select using (true);

drop policy if exists "settings_admin_write" on store_settings;
create policy "settings_admin_write" on store_settings
  for update using (is_admin()) with check (is_admin());

-- Admin allowlist: only admins can view it; nobody can edit it from the app
drop policy if exists "admin_users_admin_read" on admin_users;
create policy "admin_users_admin_read" on admin_users
  for select using (is_admin());

-- =========================================================
-- SEED: migrate the 6 existing demo products so nothing is lost
-- =========================================================
insert into products (name, category, description, features, price, old_price, discount, image, rating, reviews, badge, is_new, on_sale, featured, stock)
values
('Premium Non-Stick Cookware Set','Cookware','A durable, easy-clean cookware set for everyday cooking.',
 '["7-piece set","Non-stick coating","Heat-resistant handles","Suitable for all stovetops","Easy to clean"]',
 8999,12999,'30% OFF','🍳',4.8,124,'30% OFF',false,true,true,'In Stock'),
('Air Fryer 5.5L','Kitchen Appliances','Healthier frying with rapid air circulation and digital controls.',
 '["5.5L capacity","Digital touch panel","Rapid air circulation","Adjustable temperature","Easy-clean basket"]',
 15999,21999,'Sale','🍟',4.7,98,'Sale',false,true,true,'In Stock'),
('Premium Spice Jar Set','Storage & Organizers','Keep your spices fresh and organized in style.',
 '["12 glass jars","Airtight lids","Modern rack","Easy labeling","Kitchen-saving design"]',
 3499,4999,'New','🫙',4.6,76,'New',true,false,false,'In Stock'),
('2-Tier Dish Drying Rack','Utensils','Rust-resistant, space-saving drying rack for any kitchen.',
 '["2-tier storage","Rust-resistant frame","Drain tray","Large capacity","Space-saving"]',
 4999,7999,'New','🍽️',4.5,62,'New',true,false,false,'In Stock'),
('Bamboo Kitchen Organizer','Storage & Organizers','Natural bamboo organizer with adjustable sections.',
 '["Natural bamboo","Adjustable sections","Smooth finish","Easy to clean","Compact footprint"]',
 2899,3999,'','🥢',4.6,44,'',false,false,false,'In Stock'),
('Chef Knife 3-Piece Set','Utensils','Professional stainless steel knives with ergonomic handles.',
 '["3 professional knives","Stainless steel blades","Ergonomic handles","Protective covers","Balanced grip"]',
 3299,4499,'New','🔪',4.8,51,'New',true,false,false,'In Stock')
on conflict do nothing;

-- =========================================================
-- STORAGE: product images bucket
-- Run this part too — creates a public bucket for product photos.
-- =========================================================
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

drop policy if exists "product_images_public_read" on storage.objects;
create policy "product_images_public_read" on storage.objects
  for select using (bucket_id = 'product-images');

drop policy if exists "product_images_admin_write" on storage.objects;
create policy "product_images_admin_write" on storage.objects
  for insert with check (bucket_id = 'product-images' and is_admin());

drop policy if exists "product_images_admin_update" on storage.objects;
create policy "product_images_admin_update" on storage.objects
  for update using (bucket_id = 'product-images' and is_admin());

drop policy if exists "product_images_admin_delete" on storage.objects;
create policy "product_images_admin_delete" on storage.objects
  for delete using (bucket_id = 'product-images' and is_admin());
