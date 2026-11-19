# Supabase setup checklist

Project reference: `dowkvuzhowdchyacmbts`

Project dashboard: https://supabase.com/dashboard/project/dowkvuzhowdchyacmbts

## Current state
The SQL migration and three Edge Function source files are in this repository. They are not deployed. The browser app remains local-first; it does not yet sign in to Supabase or synchronize records. Do not treat a successful SQL migration alone as a complete cloud launch.

## Apply the database migration
1. Open the project dashboard and choose **SQL Editor**.
2. Open `supabase/migrations/0001_quotenest_cloud.sql` from this repository.
3. Review the complete SQL and run it in the project.
4. Confirm the nine tables exist and row-level security is enabled.
5. Do not paste service-role credentials into the SQL editor or browser app.

## Edge Functions
After the migration has been reviewed and applied, deploy:
- `create-public-quote-link`
- `public-quote`
- `respond-to-quote`

Set `PUBLIC_APP_URL` and `PUBLIC_APP_ORIGIN` as server-side function secrets for the eventual hosted app. Supabase supplies its own project URL and service-role key to its Edge Function runtime. Never expose the service-role key in client-side code or GitHub.

## Before real use
The browser app still needs Supabase authentication and business-scoped cloud synchronization integrated. Then test with separate test accounts:
- One business must never read another business's customers, quotes, or services.
- Public quote links must expire and be revocable.
- Only the first valid customer response should change a sent quote.
- Backup export/import and recovery should be tested.
- Review CORS, RLS, and function logs.

Payments remain disabled. Do not use real customer data until the above work is complete and reviewed.
