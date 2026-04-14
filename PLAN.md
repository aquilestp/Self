# Preservar el APNs token al desconectar y reconectar Strava

**Problema**

- Al desconectar Strava, se borra toda la fila de la base de datos, incluyendo el token de notificaciones push (`apns_token`)
- Al reconectar, el token no se puede recuperar ni de la base de datos (fue borrado) ni de memoria (puede estar vacío)

**Solución**

1. Guardar el APNs token en almacenamiento local del dispositivo cada vez que se recibe de Apple
2. Al reconectar Strava y guardar los tokens, usar el token guardado localmente como respaldo
3. Esto asegura que el token de notificaciones push siempre se preserve, sin importar cuántas veces se desconecte y reconecte Strava

