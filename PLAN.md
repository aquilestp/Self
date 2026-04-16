# Modo "sin conectar" como forma legítima de usar la app

## Idea central

Esto no es una build para Apple review — es una forma real de usar la app para cualquier usuario que no quiera (o no pueda) conectar Strava/COROS/Garmin. Internamente reutilizamos toda la maquinaria de la "demo experience" que ya tenemos (las 7 actividades pregeneradas, el flujo de editor, galería, stats), pero en la UI **no aparece en ningún lado la palabra "demo", "sample", "test", "try"**. Se presenta como lo que es: crear posts con tus fotos y elegir los stats a mano.

## Cómo lo vivirá el usuario

Cuando el usuario entra al dashboard y aún no ha conectado ningún proveedor:

1. Ve el carrusel que ya existe, pero el primer card deja de verse como "Demo Activities" y pasa a ser la **opción principal** con una propuesta clara de valor real: crear un post ya mismo sin depender de un reloj o una cuenta externa.
2. Los cards de Strava, COROS y Garmin quedan después como "además, puedes conectar tu cuenta para importar tus actividades reales".

## El card principal (reemplaza al actual "Demo Activities")

- Título: **"Create a post"**
- Subtítulo: *"Pick a workout template, drop your photo and share it."*
- Sin badge "NO ACCOUNT NEEDED". Sin mención a Strava/COROS/Garmin en el texto.
- Visual elegante y protagonista (no "secundario tipo prueba"): icono tipo sparkles/foto, acento claro.
- Acción principal (botón grande): **"Start"** → abre el listado de actividades que hoy son demo, pero presentadas como **"Workout templates"**.
- Acción secundaria (link pequeño debajo del botón): **"New post from photo"** → abre galería de fotos directamente; después de elegir foto aparece una hoja pequeña para elegir uno de esos "workout templates" como base de stats, y cae en el editor.

## Renombres de copy (toda la app)

- "Demo Activities" → **"Create a post"** (en el card)
- "Open demo" / "Opening..." → **"Start"** / **"Loading…"**
- "Open sample workouts instantly and test the full flow without Strava, COROS or Garmin" → *"Pick a workout template, drop your photo and share it."*
- En el dashboard, cuando la fuente es esta (no Strava), el título "Choose your activity" se mantiene, pero la sección de actividades se llama **"Templates"** en vez de sonar a reales.
- El botón "Try Demo" del login sigue funcionando y llama al mismo backend, pero para mantener coherencia se puede renombrar a **"Continue without account"** (opcional — dime si quieres que lo toque o lo deje).

## Settings / conectar más tarde

Sin cambios. El usuario que entró por esta vía ve en Settings la opción "Connect Strava" ya existente y puede conectar cuando quiera. Al conectar, las actividades reales toman el lugar de los templates, como hoy.

## Qué NO cambia

- Login (Apple / Google) idéntico.
- Lógica de auth, Supabase, listener — sin tocar.
- Las 7 actividades pregeneradas internas siguen igual (solo cambia cómo se presentan).
- Los cards de Strava/COROS/Garmin siguen igual en posición y diseño.

## Preguntas abiertas (respóndeme si alguna aplica, si no, sigo con lo de arriba)

1. ¿Renombro también el botón **"Try Demo"** del login a "Continue without account"? (o lo dejo igual)  
Respuesta: Elimina ese boton
2. ¿El nombre **"Create a post"** para el card te convence, o prefieres otro (p.ej. "Make a post", "New post", "Post a workout")?  
Respuesta: esta ok

## Verificación

Compilar con el builder y confirmar que el flujo completo (card → templates → editor → galería → stats → share) sigue funcionando sin tocar Strava.  
