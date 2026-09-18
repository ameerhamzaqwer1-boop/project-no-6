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

const SUPABASE_URL = "https://kcjjzfznkrdoxgkejnsc.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtjamp6Znpua3Jkb3hna2VqbnNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3MTU0MTMsImV4cCI6MjEwNTI5MTQxM30.D1NVwECcRw53u9HSmT9_04PgIrNF-M5mAkSWXW_LJ3Q";

// Your WhatsApp number in international format, digits only, no + or spaces.
// Example for a Pakistani number 0300-1234567 -> "923001234567"
const WHATSAPP_NUMBER = "923019088013";

// The email you will use to sign in as admin (created in Supabase Auth).
// This is NOT a secret — it's just used to show the right login hint.
const ADMIN_EMAIL_HINT = "ameerhamzaqwer1@gmail.com";
