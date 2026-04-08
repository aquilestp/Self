import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const STRAVA_CLIENT_ID = Deno.env.get("STRAVA_CLIENT_ID")!;
const STRAVA_CLIENT_SECRET = Deno.env.get("STRAVA_CLIENT_SECRET")!;
const STRAVA_VERIFY_TOKEN = Deno.env.get("STRAVA_VERIFY_TOKEN") ?? "SELFSPORT_WEBHOOK_VERIFY";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

interface StravaWebhookEvent {
  object_type: "activity" | "athlete";
  object_id: number;
  aspect_type: "create" | "update" | "delete";
  owner_id: number;
  subscription_id: number;
  event_time: number;
  updates?: Record<string, string>;
}

interface StravaTokenRow {
  user_id: string;
  strava_athlete_id: number;
  access_token: string;
  refresh_token: string;
  expires_at: number;
}

async function refreshStravaToken(row: StravaTokenRow): Promise<string | null> {
  const res = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: STRAVA_CLIENT_ID,
      client_secret: STRAVA_CLIENT_SECRET,
      refresh_token: row.refresh_token,
      grant_type: "refresh_token",
    }),
  });

  if (!res.ok) return null;

  const data = await res.json();

  await supabase.from("strava_tokens").update({
    access_token: data.access_token,
    refresh_token: data.refresh_token,
    expires_at: data.expires_at,
    updated_at: new Date().toISOString(),
  }).eq("user_id", row.user_id);

  return data.access_token as string;
}

async function getValidAccessToken(row: StravaTokenRow): Promise<string | null> {
  const now = Math.floor(Date.now() / 1000);
  if (now < row.expires_at - 300) return row.access_token;
  return await refreshStravaToken(row);
}

async function fetchAndStoreActivity(
  stravaActivityId: number,
  ownerStravaId: number,
) {
  const { data: tokenRow } = await supabase
    .from("strava_tokens")
    .select("*")
    .eq("strava_athlete_id", ownerStravaId)
    .single();

  if (!tokenRow) return;

  const accessToken = await getValidAccessToken(tokenRow as StravaTokenRow);
  if (!accessToken) return;

  const res = await fetch(
    `https://www.strava.com/api/v3/activities/${stravaActivityId}`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );

  if (!res.ok) return;

  const activity = await res.json();

  const row = {
    user_id: tokenRow.user_id,
    strava_activity_id: activity.id,
    name: activity.name,
    type: activity.type,
    sport_type: activity.sport_type ?? null,
    distance: activity.distance,
    moving_time: activity.moving_time,
    elapsed_time: activity.elapsed_time,
    total_elevation_gain: activity.total_elevation_gain,
    start_date_local: activity.start_date_local,
    summary_polyline: activity.map?.summary_polyline ?? null,
    average_speed: activity.average_speed ?? null,
    max_speed: activity.max_speed ?? null,
    has_heartrate: activity.has_heartrate ?? false,
    average_heartrate: activity.average_heartrate ?? null,
    synced_by_webhook: true,
  };

  await supabase
    .from("strava_activities")
    .upsert(row, { onConflict: "user_id,strava_activity_id" });
}

async function deleteActivity(stravaActivityId: number, ownerStravaId: number) {
  const { data: tokenRow } = await supabase
    .from("strava_tokens")
    .select("user_id")
    .eq("strava_athlete_id", ownerStravaId)
    .single();

  if (!tokenRow) return;

  await supabase
    .from("strava_activities")
    .delete()
    .eq("user_id", tokenRow.user_id)
    .eq("strava_activity_id", stravaActivityId);
}

async function handleDeauthorization(ownerStravaId: number) {
  const { data: tokenRow } = await supabase
    .from("strava_tokens")
    .select("user_id")
    .eq("strava_athlete_id", ownerStravaId)
    .single();

  if (!tokenRow) return;

  await supabase
    .from("strava_tokens")
    .delete()
    .eq("strava_athlete_id", ownerStravaId);
}

Deno.serve(async (req) => {
  if (req.method === "GET") {
    const url = new URL(req.url);
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    if (mode === "subscribe" && token === STRAVA_VERIFY_TOKEN) {
      return new Response(JSON.stringify({ "hub.challenge": challenge }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response("Forbidden", { status: 403 });
  }

  if (req.method === "POST") {
    try {
      const event: StravaWebhookEvent = await req.json();

      if (event.object_type === "activity") {
        if (event.aspect_type === "create" || event.aspect_type === "update") {
          await fetchAndStoreActivity(event.object_id, event.owner_id);
        } else if (event.aspect_type === "delete") {
          await deleteActivity(event.object_id, event.owner_id);
        }
      } else if (event.object_type === "athlete") {
        if (event.updates?.["authorized"] === "false") {
          await handleDeauthorization(event.owner_id);
        }
      }
    } catch (e) {
      console.error("Webhook processing error:", e);
    }

    return new Response("OK", { status: 200 });
  }

  return new Response("Method not allowed", { status: 405 });
});
