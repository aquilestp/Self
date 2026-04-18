# Eliminar Apple Health completamente de la app


## Cambios

**Archivos a eliminar:**
- `HealthKitViewModel.swift` — lógica de conexión y carga de workouts
- `HealthKitService.swift` — integración nativa con HealthKit
- `HealthKitActivityType.swift` — mapeo de tipos de actividad de HealthKit

**Archivos a modificar:**

- **`ActiveSource.swift`** — quitar el caso `.appleHealth`, dejar solo `.strava`
- **`DashboardRootView.swift`** — eliminar `healthKitViewModel`, simplificar todos los `switch` que tenían `.appleHealth`, quitar el alert de Apple Health, quitar `onConnectAppleHealth` / `onDisconnectAppleHealth`, quitar `connectAppleHealth()`
- **`SettingsView.swift`** — quitar parámetros `isAppleHealthConnected`, `onDisconnectAppleHealth`, `onConnectAppleHealth`, quitar el confirmation dialog de Apple Health, simplificar `sourceAccent` y `sourceIcon`
- **`DashboardCards.swift`** — quitar el row de "Apple Health" del `ConnectProvidersSheet`, quitar `onConnectAppleHealth`, simplificar `EmptyActivitiesCard`
- **`WelcomeOnboardingView.swift`** — quitar el `WelcomeProviderPreviewRow` de Apple Health
- **`project.pbxproj`** — quitar la capability `com.apple.HealthKit` y los `INFOPLIST_KEY_NSHealthUpdateUsageDescription`
