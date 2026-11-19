# QuoteNest

**BUILD MORE. QUOTE SMARTER.**

QuoteNest is a quotation workspace for independent service businesses and freelancers. The integrated V6–V8 local-first app includes customer and service management, multi-line quotes, Good/Better/Best packages, quote history, profit estimates, tax and currency settings, backup/restore, and a customer decision-tracking centre.

## Files
- `index.html` — responsive local-first browser app. Data is stored in this browser's local storage.
- `quote.html` — customer-facing quote review page for the future hosted Supabase link flow.
- `supabase/migrations/0001_quotenest_cloud.sql` — PostgreSQL schema and row-level security policies.
- `supabase/functions/` — server-side public quote-link creation, retrieval, and response endpoints.
- `QA-STATUS.json` — current verification and deployment status.

## Preview
Open `index.html` in a modern browser. Add customers, services, create quotes, track decisions, print/save quote previews as PDF, and export/restore a JSON backup.

## Cloud status
The Supabase schema and Edge Function source are committed, but the current browser app is still local-first: account sign-in and cloud synchronization are not wired into its UI yet. Public online customer approvals are therefore not live. The SQL migration has not been applied and the Edge Functions have not been deployed.

Before enabling cloud features:
1. Review and apply the migration in a development Supabase project.
2. Integrate Supabase authentication and business-scoped synchronization in the browser app.
3. Deploy the Edge Functions and set `PUBLIC_APP_URL` and `PUBLIC_APP_ORIGIN` as server-side function secrets.
4. Host both `index.html` and `quote.html` on the same trusted origin.
5. Test account isolation, quote link expiry/revocation, approval/decline, and data recovery using test accounts.

Never put a Supabase service-role key in browser code or commit it to Git.

## Release status
This is a development build, not production-ready. Payments are intentionally disabled. Do not use real customer data until cloud authentication, access controls, deployment, and end-to-end security testing are complete.
