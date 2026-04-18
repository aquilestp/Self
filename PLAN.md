# Apple Health Integration — Import workouts alongside Strava

## Overview

Add Apple Health as a full activity source in SelfSport. Users can choose between Strava and Apple Health — only one is active at a time. Switching sources is non-destructive: Strava data stays saved, and Apple Health data is always pulled fresh from the device.

---

## Features

- **Apple Health row in "Connect a service" sheet** — new entry with a red heart icon, placed below Strava. Tapping it triggers the standard Apple Health permission dialog (iOS native system sheet).
- **One active source at a time** — the active source (Strava or Apple Health) is saved locally on the device. Switching activates the new source without deleting the other's data.
- **Strava → not deleted when switching** — Strava workouts remain in the database. If the user switches back, Strava reloads from cache instantly.
- **Apple Health → always on-device** — HealthKit workouts are read directly from the device (no need to store them in the cloud database). They stay fresh automatically.
- **Import all workout types** — runs, rides, swims, gym sessions, hikes, HIIT, yoga, tennis, basketball, and more — all converted to the same card format used by Strava activities.
- **Same data shown on cards** — distance, duration, pace, elevation, average heart rate, and workout type icon — all pulled from Apple Health the same way Strava provides them.
- **Settings screen** — shows Apple Health as "Connected" when active, with a button to disconnect (switch back to Strava or no source). Note: HealthKit permissions themselves live in iPhone Settings; the app manages which source is active.
- **"Disconnect" behavior** — disconnecting Apple Health in the app just deactivates it as the active source. The user's HealthKit permission stays intact (iOS doesn't allow apps to revoke it programmatically, by Apple design).
- **Onboarding preview** — Apple Health appears in the onboarding sources list so new users know it's an option.

---

## Design

- **Apple Health icon**: red heart (`heart.fill`) with a red accent circle, consistent with how Strava uses its orange icon
- **Connect button**: same style as the existing Strava connect button — not marked "Soon", fully functional
- **Permission dialog**: iOS system sheet (Apple's own UI) — no custom UI needed
- **Activity cards**: identical look to Strava cards — reuses the same `ActivityHighlight` model, so all existing stat widgets, templates, and the photo editor work with Apple Health workouts out of the box
- **Source indicator**: subtle label on the activity feed (e.g. "Apple Health" or "Strava") so users know which source is active

---

## Technical Approach (for the developer's reference — not code specifics)

- Add HealthKit capability to the app's entitlements file
- Add Health usage description permission to the app's Info settings
- Create a new HealthKit service that reads workouts from the device
- Create a new HealthKit view model mirroring the existing Strava one
- Store the "active source" choice in device memory (UserDefaults) — no backend change needed
- The dashboard detects which source is active and shows the right activity list
- Strava's Supabase data is untouched when switching to Apple Health

