# Speed up Strava connection by removing push notification sync

## Problem
The Strava login flow is extremely slow because it waits for push notification (APNs) token registration and syncing — adding up to **22+ seconds** of delays during the connection process.

## What will change

**Strava Connection (StravaService)**
- Remove the push re-registration call and 2-second sleep during token exchange
- Remove the aggressive APNs retry loop (`ensureAPNsTokenSynced`) that can block for up to 20 seconds
- The token exchange will now just: get the code → exchange with Strava → save tokens → sync to Supabase (without APNs) → done

**Token Sync (SupabaseTokenService)**
- Remove all APNs-related fields from the sync process — no more `apns_token` writes
- Remove the `syncAPNsTokenToDB`, `startPendingAPNsSync`, and `ensureAPNsTokenSynced` methods
- Keep the core Strava token sync (access token, refresh token, expires at, athlete ID)

**App Startup & Foreground (SelfSportApp)**
- Remove the foreground re-register + 2-second sleep + APNs DB sync
- Remove the APNs token change listener
- Remove the initial 3-second delayed APNs sync on launch

**AppDelegate**
- Keep basic push registration (in case you re-enable later), but remove the DB sync call when token arrives

**NotificationService**
- Keep the service intact (local notifications still work), but its token is no longer synced to the database

## What stays the same
- Strava OAuth flow and activity fetching — unchanged
- Local notifications — still work
- The `strava_tokens` table still gets Strava tokens synced — just without the `apns_token` column being written
- Push notification permission prompts — still work if needed later

## Result
Strava connection should complete in **1-3 seconds** instead of 20+.