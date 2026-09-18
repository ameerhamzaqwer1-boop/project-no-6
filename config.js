/*
  KITCHEN CRAT PK — CONFIGURATION
  ================================
  Fill these three values in, then upload this file to GitHub along with
  the rest of the site. See README.md, section "Setup Guide", for exactly
  how to get each value.

  SAFE TO BE PUBLIC:
  - SUPABASE_URL and SUPABASE_ANON_KEY are meant to be visible in frontend
    code. The anon key can only do what your Row Level Security (RLS)
    policies allow (defined in supabase-schema.sql) — it can NEVER bypass
    them, so it is safe to publish on GitHub Pages.
  - Never put a Supabase "service_role" key here. That key bypasses RLS
    entirely and must never appear in any file that goes to GitHub.
*/

const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";

// Your WhatsApp number in international format, digits only, no + or spaces.
// Example for a Pakistani number 0300-1234567 -> "923001234567"
const WHATSAPP_NUMBER = "923XXXXXXXXX";

// The email you will use to sign in as admin (created in Supabase Auth).
// This is NOT a secret — it's just used to show the right login hint.
const ADMIN_EMAIL_HINT = "admin@kitchencratpk.com";
