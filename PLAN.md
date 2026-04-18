# Fix Apple Health connect — show permission dialog & errors


## Root Cause
When "Connect with Apple Health" is tapped, the sheet dismisses correctly — but then `connect()` runs and either:
- **On simulator**: HealthKit is unavailable → sets `errorMessage` silently (nothing shown)
- **On real device**: The system HealthKit permission dialog should appear, but if any error occurs it's also swallowed silently

`healthKitViewModel.errorMessage` is set in several places but **no alert is wired up anywhere** to actually display it to the user.

## Fix

**Add a `.alert` modifier in `DashboardRootView`** that watches `healthKitViewModel.errorMessage`:
- When the error message is non-nil, show an alert with the message
- Dismissing the alert clears the error
- This handles: "Apple Health is not available on this device." (simulator), authorization errors, and load failures

That's the only change needed — the HealthKit permission flow itself is correctly implemented and will work on a real device once the error is visible.
