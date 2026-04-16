# Delete account from Settings with confirmation

**What will be added**

- A new **Danger Zone** section at the bottom of the Settings screen with a **Delete Account** button (red, destructive styling, matching the existing Sign Out card look).
- Tapping it shows a native iOS confirmation alert with the title **"Delete Account"**, message **"This will permanently delete your account and all associated data. This action cannot be undone."**, and two actions: **Cancel** and **Delete** (destructive red).
- On confirm, the app calls a secure server-side deletion (Supabase RPC `delete_user`) that removes the user's auth record and profile, then signs the user out locally and returns them to the login screen.
- While deletion is running, the button shows a small spinner and is disabled to prevent double taps. If the server call fails, an inline error alert appears.
- For demo mode users (not a real account), the button simply exits the demo session — no server call.

**Design**

- Section header "DANGER ZONE" with a small `exclamationmark.triangle.fill` icon, same muted tracking-style as other section labels.
- Card with the same dark translucent background as other Settings cards; red text + red trailing `trash` SF Symbol.
- Confirmation uses the standard iOS destructive alert (native look, red Delete button).

**Note on backend**

- Requires a one-time SQL function in Supabase (`delete_user()` RPC using `auth.admin`) so the signed-in user can trigger deletion of their own account securely. I'll include the SQL snippet to paste into the Supabase SQL editor.

