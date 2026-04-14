# Fix Strava token sync — add logging and fix silent failures

## Problem
When the app connects to Strava, the access/refresh tokens are saved locally (Keychain) but **never reach the Supabase `strava_tokens` table**. The webhook can't fetch activity details because it has no token.

The token sync fails silently because:
1. `currentUserId()` might return `nil` if there's no active Supabase session — exits without warning
2. The Supabase upsert error is caught and swallowed (empty `catch` block)

## Fix
- **Add print/logging** in `syncTokens()` so you can see in console whether:
  - The user ID was found or not
  - The upsert succeeded or failed (and the actual error message)
- **Add logging** in `exchangeToken()` to confirm the athlete ID is being passed correctly
- **Add logging** in `deleteTokens()` for visibility

This way, when you reconnect Strava, you'll see exactly what's happening and can identify the root cause (missing Supabase session, RLS policy blocking the insert, etc.)
