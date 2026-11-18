# QuoteNest

**BUILD MORE. QUOTE SMARTER.**

QuoteNest is a quotation-management app for small service businesses and freelancers.

## Planned product capabilities
- Customer and service catalogues
- Multi-line quotations with tax and profit estimates
- Good / Better / Best quote packages
- Customer-facing quote pages and approval workflow
- Quote statuses, history, reminders and analytics
- Multi-currency settings and data backup/export

## Release status
The V6–V8 release package has been prepared, including a browser app, a public quote page, a Supabase migration, and Edge Function source files.

**Important:** source deployment, database migration, security review, and end-to-end testing must be completed before using this with real customer data. Payments are not enabled.

## Backend setup
1. Create or select a Supabase project.
2. Apply the migration in `supabase/migrations/0001_quotenest_cloud.sql`.
3. Configure the Supabase project URL and public client key in the app.
4. Deploy the Edge Functions in `supabase/functions/`.
5. Keep the Supabase service-role key server-side only.

See `QA-STATUS.json` for known release limitations.
