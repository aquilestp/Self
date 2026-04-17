# Connected Apps row en Settings abre drawer de conexión o desconexión

## Qué cambia

### Comportamiento del row "Connected app" en Settings

**Sin conexión activa:**

- El row "Connected app" se vuelve tappable (aparece un chevron `>` a la derecha)
- Al tocarlo, se abre el mismo drawer de "Connect a service" (Strava, COROS, Garmin)
- Mismo flujo que el botón "See connections" del dashboard

**Con conexión activa (ej. Strava):**

- El row ya muestra el nombre de la app conectada en verde
- Al tocarlo, aparece el diálogo de confirmación de desconexión que ya existe
- El botón "Disconnect Strava" inline que hay debajo desaparece (el tap en el row ya lo cubre)

### Cambios técnicos

- `SettingsView` recibe un nuevo callback `onConnectStrava`
- El row "Connected app" se convierte en botón con comportamiento condicional
- Al no estar conectado: abre `ConnectProvidersSheet` como sheet desde Settings
- Al estar conectado: dispara el diálogo de desconexión existente
- `DashboardRootView` pasa el callback `onConnectStrava` a `SettingsView`

