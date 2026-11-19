import {createClient} from "https://esm.sh/@supabase/supabase-js@2";
import {adminClient,corsHeaders,json,newToken,hashToken} from "../_shared.ts";
Deno.serve(async req=>{if(req.method==="OPTIONS")return new Response("ok",{headers:corsHeaders});if(req.method!=="POST")return json({error:"Method not allowed."},405);try{
const authorization=req.headers.get("Authorization");if(!authorization?.startsWith("Bearer "))return json({error:"Sign in is required."},401);
const url=Deno.env.get("SUPABASE_URL"),anon=Deno.env.get("SUPABASE_ANON_KEY");if(!url||!anon)return json({error:"Server configuration is incomplete."},500);
const userClient=createClient(url,anon,{global:{headers:{Authorization:authorization}},auth:{persistSession:false,autoRefreshToken:false}});
const {data:authData,error:authError}=await userClient.auth.getUser();if(authError||!authData.user)return json({error:"Your session is invalid."},401);
const body=await req.json().catch(()=>({})),quoteId=body?.quote_id;if(typeof quoteId!=="string"||!/^[0-9a-f-]{36}$/i.test(quoteId))return json({error:"A valid quote_id is required."},400);
const admin=adminClient();const {data:quote,error:qe}=await admin.from("quotes").select("id,business_id,status").eq("id",quoteId).maybeSingle();if(qe)throw qe;if(!quote)return json({error:"Quote not found."},404);
const {data:member,error:me}=await admin.from("business_members").select("role").eq("business_id",quote.business_id).eq("user_id",authData.user.id).maybeSingle();if(me)throw me;if(!member||!["owner","admin","member"].includes(member.role))return json({error:"You cannot share this quote."},403);
if(quote.status!=="Sent")return json({error:"Only sent quotes can be shared."},409);
const days=Math.min(30,Math.max(1,Number(body?.expires_in_days)||14)),token=newToken(),expiresAt=new Date(Date.now()+days*86400000).toISOString();
const {error:le}=await admin.from("quote_public_links").upsert({quote_id:quoteId,token_hash:await hashToken(token),expires_at:expiresAt,revoked_at:null},{onConflict:"quote_id"});if(le)throw le;
await admin.from("quote_events").insert({quote_id:quoteId,event_type:"link_created"});const app=Deno.env.get("PUBLIC_APP_URL");if(!app)return json({error:"PUBLIC_APP_URL is not configured."},500);
return json({url:`${app.replace(/\/+$/,"")}/quote.html?token=${token}`,expires_at:expiresAt});
}catch(e){console.error("create-public-quote-link",e);return json({error:"Unable to create the customer link."},500)}});