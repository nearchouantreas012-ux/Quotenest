# QuoteNest — Supabase authentication and cloud sync

Supabase project reference: `dowkvuzhowdchyacmbts`

Dashboard: https://supabase.com/dashboard/project/dowkvuzhowdchyacmbts

## What is integrated in the app

- Supabase JS v2 client loaded from the CDN.
- Email/password sign-up, sign-in, persistent sessions, and sign-out.
- One owner workspace per account.
- Cloud storage for customers, services, quotes, quote line items, business settings, estimated costs and profit.
- Initial import: if the cloud workspace is empty, the app uploads existing local browser data. If cloud records already exist, the app loads cloud data.
- Debounced sync after app changes.
- Realtime refresh subscriptions for customers, services and quotes.
- Account separation: changing account on the same browser clears the previous account's cached customer, service and quote data before loading the new account.

The app stores only the Supabase **publishable/anon key** in browser local storage. Never use a service-role or secret key in the browser.

## Required one-time setup

1. Open the Supabase dashboard above.
2. Go to **Project Settings → API Keys** (or **Settings → API** in the older dashboard).
3. Copy the **publishable** key (or legacy anon/public key). Do not copy a secret/service-role key.
4. Open the hosted QuoteNest app over HTTPS.
5. Go to **Settings & workspace → Cloud account & sync**, paste the publishable key, and choose **Save key**.
6. Open the SQL Editor in Supabase. Copy and run the complete file `supabase/migrations/0001_quotenest_cloud.sql` from this repository.
7. Create an account in the app. If email confirmation is enabled, confirm the email and then sign in.
8. Create a test customer and quote. Check that rows appear in Supabase Table Editor. Sign in on a second browser/device to test cloud loading.

## Supabase Auth URL configuration

In **Authentication → URL Configuration**, set the Site URL to the hosted QuoteNest HTTPS address and add that address to the Redirect URLs allow-list. The sign-up confirmation link returns to the current app URL.

## Data and safety notes

- The first account to sign in can import existing local browser records when its cloud workspace is empty.
- If a different account signs in on the same browser, the previous account's cached business records are cleared before the new account is loaded.
- Sync is currently a simple workspace mirror, not a conflict-resolution engine. Avoid editing the same quote simultaneously on two devices until conflict handling is added.
- RLS is enabled in the migration. Do not store real customer data until the migration has been applied and tested with two separate accounts.
- Public quote-link Edge Functions are separate from sign-in/sync and still need deployment and end-to-end tests.
- Payments remain disabled.
