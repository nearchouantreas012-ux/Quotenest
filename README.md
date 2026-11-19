# QuoteNest

**BUILD MORE. QUOTE SMARTER.**

QuoteNest is a quotation workspace for independent service businesses and freelancers. The integrated V6–V8 interface includes customer and service management, multi-line quotes, Good/Better/Best packages, quote history, profit estimates, currency/tax settings, backup/restore, and customer review workflows.

## Project files
- `index.html` — integrated V6–V8 browser application with optional Supabase connection.
- `quote.html` — customer-facing quote review and response page.
- `supabase/migrations/0001_quotenest_cloud.sql` — PostgreSQL schema and row-level security.
- `supabase/functions/` — server-side public quote-link creation, retrieval, and response endpoints.

## Local preview
Open `index.html` in a modern browser. Until Supabase is configured, the app uses local browser storage.

## Supabase deployment
1. Review the SQL migration in a development environment, then apply it using the Supabase SQL Editor or CLI.
2. Configure the app with the project URL and publishable/anon key only. Never put a service-role key in browser code.
3. Deploy the three Edge Functions: `create-public-quote-link`, `public-quote`, and `respond-to-quote`.
4. Set server-side function secrets `PUBLIC_APP_URL` and `PUBLIC_APP_ORIGIN` to the hosted app URL/origin.
5. Test with separate test accounts and sample quotes before real customer use.

## Verification
Browser source checks passed in the previous QA pass. GitHub write access is connected. The live Supabase migration and functions have not yet been deployed or tested. Billing and checkout are intentionally disabled.

This is a development release, not production-ready. Review RLS policies, public quote endpoints, and account isolation before using real customer data.
