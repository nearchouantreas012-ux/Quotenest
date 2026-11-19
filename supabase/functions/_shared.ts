import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
export const corsHeaders={"Access-Control-Allow-Origin":Deno.env.get("PUBLIC_APP_ORIGIN")??"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"GET, POST, OPTIONS"};
export function json(data:unknown,status=200){return new Response(JSON.stringify(data),{status,headers:{...corsHeaders,"Content-Type":"application/json","Cache-Control":"no-store"}})}
export function adminClient(){const url=Deno.env.get("SUPABASE_URL"),key=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");if(!url||!key)throw Error("Server configuration is incomplete.");return createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}})}
export async function hashToken(token:string){const digest=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(token));return [...new Uint8Array(digest)].map(b=>b.toString(16).padStart(2,"0")).join("")}
export function newToken(){return [...crypto.getRandomValues(new Uint8Array(32))].map(b=>b.toString(16).padStart(2,"0")).join("")}
export const isHexToken=(v:unknown):v is string=>typeof v==="string"&&/^[a-f0-9]{64}$/.test(v);
export const isActiveLink=(l:any)=>!!l&&!l.revoked_at&&new Date(l.expires_at).getTime()>Date.now();
