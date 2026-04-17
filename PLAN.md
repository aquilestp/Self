# Toggle verde y arreglo del contador de generaciones AI

## Cambios

**1. Toggle "Include stats overlay" en verde**
- Cambiar el color del toggle (actualmente blanco semitransparente) a verde del sistema, que es el color nativo y esperado de los toggles en iOS.

**2. Arreglo del contador de generaciones AI**

Diagnóstico: el contador solo se incrementa si la generación termina con éxito Y el usuario acepta (o incluso si descarta). Actualmente el registro sucede después de que la imagen se genera, pero si Supabase falla silenciosamente (por ejemplo, por permisos RLS o usuario no autenticado correctamente), el error solo se imprime en consola y el usuario no se entera.

Voy a:
- Revisar el flujo y confirmar que `recordUsage` se ejecuta tras una generación exitosa (ya lo hace, pero puede estar fallando silenciosamente).
- Añadir logs más claros y verificar el error exacto que devuelve Supabase al insertar en `ai_generations`.
- Asegurar que tras insertar se refresca el estado visible del contador.
- Si el fallo es de RLS / políticas / columnas en la tabla, indicarte qué ajustar en Supabase (probablemente falta la política de INSERT para el usuario autenticado, o la columna `user_id` tiene un default distinto).

Con los logs visibles podré decirte con precisión qué falta configurar del lado de Supabase (si es el caso) o arreglar el código si el problema está ahí.