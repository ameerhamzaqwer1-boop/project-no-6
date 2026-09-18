# Kitchen Crat PK — Setup Guide

A professional kitchen e-commerce site with a real online admin panel,
product management, order management, and WhatsApp ordering — hosted
free on GitHub Pages, with Supabase as the online backend.

This guide assumes **no coding experience**. Follow it top to bottom.

---

## What changed from your old site

- Kept your exact design (dark green + gold theme, header, hero, categories,
  product cards, footer, animations, mobile layout).
- The old "Admin" button only saved changes in *your own browser*
  (`localStorage`) — nobody else could see your edits. That's been replaced
  with a **real online backend (Supabase)**: when you add/edit/delete a
  product or update an order, every visitor sees the change immediately.
- Added: shopping cart drawer, full checkout form, WhatsApp order handoff,
  order storage + an Orders tab in Admin, search/filter/sort, wishlist,
  image uploads, and a Settings tab.
- **Until you finish the Supabase setup below, the site runs in "Demo Mode"**
  — it still works and looks the same, but admin changes only save in your
  own browser (same limitation as before). Once Supabase is connected, it
  switches to fully online automatically — no code changes needed.

---

## Part A — Create your Supabase project (free)

1. Go to [supabase.com](https://supabase.com) and sign up (free tier is enough).
2. Click **New Project**. Pick any name (e.g. `kitchen-crat-pk`), set a
   database password (save it somewhere safe — you won't need it day-to-day),
   choose the region closest to Pakistan, and click **Create**. Wait ~2 minutes.

## Part B — Create the database tables

1. In your Supabase project, open **SQL Editor** (left sidebar) → **New query**.
2. Open the file `supabase-schema.sql` (included in this project) in a text
   editor, copy **all of it**, paste it into the SQL Editor, and click **Run**.
3. This creates the `products`, `orders`, `store_settings`, and `admin_users`
   tables, sets up security rules, creates the image storage bucket, and
   loads your 6 existing products so nothing is lost.

**Important — set your admin email:** near the top of `supabase-schema.sql`
there's this line:

```sql
insert into admin_users (email) values ('admin@kitchencratpk.com')
```

Change `admin@kitchencratpk.com` to the email you'll actually use to log in
(you'll create this login in Part C). If you already ran the SQL with the
default email, you can re-run just this line with your real email afterward.

## Part C — Create your admin login

1. In Supabase, go to **Authentication → Users → Add user → Create new user**.
2. Enter the **same email** you put in `admin_users` in Part B, and a password.
   You can use the password you originally requested (`@Ah882008`) here, or
   choose your own — either way it's stored securely by Supabase, never in
   your website's code.
3. Click **Create user**. That's your admin login for the website's Admin panel.
4. **To change your password later:** Authentication → Users → click your
   user → **Reset password**, or use "Forgot password" once email sending is
   configured.

## Part D — Get your API keys

1. In Supabase, go to **Project Settings → API**.
2. Copy the **Project URL** and the **anon / public** key.
   (Never copy the `service_role` key into this project — that one is secret
   and must never go on GitHub.)

## Part E — Fill in `config.js`

Open `config.js` in this project and replace the placeholders:

```js
const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";   // from Part D
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";               // from Part D
const WHATSAPP_NUMBER = "923XXXXXXXXX";                          // your WhatsApp, digits only
const ADMIN_EMAIL_HINT = "admin@kitchencratpk.com";              // the email from Part C
```

For `WHATSAPP_NUMBER`: use the international format with no `+`, spaces or
leading zero. Example: a Pakistani number `0300-1234567` becomes
`"923001234567"`.

## Part F — Test locally (optional but recommended)

1. Keep `index.html`, `config.js`, `supabase-schema.sql`, `README.md` and the
   `assets` folder together in one folder.
2. Double-click `index.html` to open it in your browser, or better, use a
   simple local server (e.g. the VS Code "Live Server" extension) so images
   and scripts load correctly.
3. Click **Admin**, log in with the email/password from Part C, and confirm
   you can see and edit products.
4. Add a test item to the cart and place a test order — it should open
   WhatsApp with a pre-filled message, and the order should appear under
   Admin → Orders.

## Part G — Upload to GitHub

1. If you don't already have one, create a **public** GitHub repository.
2. Upload these files, keeping the same structure:
   - `index.html`
   - `config.js`
   - `supabase-schema.sql`
   - `README.md`
   - `assets/logo.svg`
3. Commit the changes.

## Part H — Enable GitHub Pages

1. In your repository, go to **Settings → Pages**.
2. Under **Build and deployment**, choose **Deploy from a branch**.
3. Select branch `main` and folder `/ (root)`, then **Save**.
4. GitHub will give you a free `https://yourusername.github.io/reponame/`
   address within a minute or two.

## Part I — Update the website later

- **Products/orders:** just log into Admin on the live site — changes are
  saved to Supabase immediately, no GitHub upload needed.
- **Design/code changes:** edit `index.html` locally and re-upload it to
  GitHub (or edit directly in GitHub's web editor). GitHub Pages updates
  automatically within a minute of a commit.

---

## Security notes

- The `anon` key in `config.js` is meant to be public — it can only do what
  the Row Level Security (RLS) rules in `supabase-schema.sql` allow. Those
  rules say: anyone can *read* products and *submit* an order, but only the
  email(s) listed in `admin_users` can create/edit/delete products, view
  orders, or change settings.
- Never paste a Supabase `service_role` key into this project.
- If you ever suspect your admin password is compromised, reset it in
  Supabase → Authentication → Users, and if needed remove the account from
  `admin_users` and add a new one.

## Limitations to know about

- **GitHub Pages itself is still just static file hosting** — all the real
  "backend" work (auth, database, storage, security rules) happens in
  Supabase, which has its own free tier limits (500MB database, 1GB storage,
  50,000 monthly active users on the free plan — plenty for a small store).
- **Payments:** this uses Cash on Delivery + WhatsApp ordering only, as
  requested. No online payment gateway is integrated.
- **Multiple admins:** you can add more admin emails by inserting more rows
  into `admin_users` (Supabase → Table Editor → admin_users) and creating a
  matching Auth user for each.
- **Emoji images:** any product without a real image URL still shows as an
  emoji (matching your original design) — upload a photo any time from the
  Add/Edit Product form to replace it.
