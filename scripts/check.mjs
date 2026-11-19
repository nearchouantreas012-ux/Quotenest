import { readFileSync, existsSync } from "node:fs";
import vm from "node:vm";

const errors = [];
for (const file of ["index.html", "quote.html"]) {
  const html = readFileSync(file, "utf8");
  const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/gi)];
  if (!scripts.length) errors.push(file + ": no inline script found");
  for (const [i, match] of scripts.entries()) {
    try { new vm.Script(match[1], { filename: file + "#script" + (i + 1) }); }
    catch (error) { errors.push(file + ": " + error.message); }
  }
}
const migration = readFileSync("supabase/migrations/0001_quotenest_cloud.sql", "utf8");
const tables = ["businesses","business_members","customers","services","quotes","quote_items","quote_public_links","quote_events","subscriptions"];
for (const table of tables) {
  if (!new RegExp("alter\\s+table\\s+public\\." + table + "\\s+enable\\s+row\\s+level\\s+security", "i").test(migration))
    errors.push("RLS missing for " + table);
}
for (const file of [
  "supabase/functions/_shared.ts",
  "supabase/functions/create-public-quote-link/index.ts",
  "supabase/functions/public-quote/index.ts",
  "supabase/functions/respond-to-quote/index.ts"
]) if (!existsSync(file)) errors.push("Missing backend source: " + file);
if (/SUPABASE_SERVICE_ROLE_KEY\s*[:=]\s*["'][^"']+["']/.test(readFileSync("index.html", "utf8")))
  errors.push("Possible service-role key literal in browser source");
if (errors.length) { console.error(errors.join("\n")); process.exit(1); }
console.log("QuoteNest source checks passed.");
