# Comunicar claramente edición AI, cuota y renovación en el drawer

## Objetivo

Que al abrir el drawer de "Edit Style" el usuario entienda de inmediato tres cosas, sin saturar la pantalla:

1. **Qué hace**: editar su foto con AI
2. **Cuánto le queda**: X de 10 imágenes este ciclo
3. **Cuándo se renueva**: 30 días después de su primera generación

## Cambios en el drawer

### 1. Encabezado más claro

- Reemplazar el título "EDIT STYLE" por un bloque más expresivo con dos líneas:
  - Título: **"Edit with AI"** (tipografía principal, no uppercase diminuto)
  - Subtítulo: **"Reimagine tu foto en un estilo nuevo"** (secundario, pequeño, opacidad baja)
- Esto da contexto inmediato de que la sección usa AI, sin depender solo del botón "Self ai" de la parte superior.

### 2. Chip de cuota mejorado (reemplaza "10/10 images")

El chip actual es funcional pero frío. Lo convertimos en un **indicador visual con progreso** y lo hacemos **tappable** para revelar el detalle de renovación.

Estado visual del chip:

- Ícono de destello / sparkles
- Texto: **"8 of 10 left"** (más humano que "8/10 images")
- Mini barra de progreso circular o lineal sutil que acompaña el texto, coloreada según cuánto queda:
  - Verde/blanco suave cuando quedan ≥ 4
  - Ámbar cuando quedan 2–3
  - Rojo suave cuando queda 1 o 0
- Al tocar el chip → abre un **popover / mini sheet** con la explicación de renovación.

### 3. Popover de detalle (al tocar el chip)

Un tooltip elegante estilo iOS (tarjeta flotante con blur y borde sutil) que muestra:

- **Título**: "Tu plan gratis"
- **Progreso visual**: barra o anillo grande mostrando "8 / 10 imágenes usadas este ciclo"
- **Línea de renovación** (dinámica según el estado del usuario):
  - Si ya generó al menos una: *"Tu cuota se renueva el **15 de mayo** (en 28 días)"* con ícono de calendario
  - Si aún no ha generado ninguna: *"Tus 30 días comienzan con tu primera generación"* con ícono de chispa
  - Si llegó al límite: *"Vuelves a tener imágenes el **15 de mayo**"* en tono ámbar/rojo
- **Nota fina al pie**: "Cada imagen que generas se cuenta por 30 días desde su creación."
- Botón "Got it" para cerrar.

### 4. Micro-texto permanente debajo del botón Generate

Una línea discreta justo debajo del botón "Generate" que siempre recuerda el costo de la acción:

- *"Uses 1 of your 10 monthly AI images"* en opacidad baja, centrado, tamaño chico.
- Cuando queda 1: *"Last image of the cycle — renews on May 15"* en ámbar.
- Cuando queda 0: *"Cycle limit reached — renews on May 15"* (el botón ya muestra el paywall al tocarlo).

## Diseño y tono

- Mantener la estética oscura con blur del drawer actual.
- Tipografías: SF Pro con pesos variados (semibold para números, regular para descripción).
- Colores semánticos para el estado: blanco translúcido → ámbar → rojo suave.
- Animación spring al abrir/cerrar el popover; haptic ligero al tocar el chip.
- Todo el texto en el idioma que ya usa la app (revisaré si es inglés o español y lo unificaré).

## Estados que se cubren

- **Usuario nuevo** (0 generaciones): muestra "10 of 10 left" y el popover dice "comienzan con tu primera generación".
- **Usuario en uso** (1–9): muestra progreso y fecha concreta de renovación de la más vieja.
- **Usuario en el límite** (10/10): chip en rojo, micro-texto rojo, botón Generate abre paywall como ya hace.

## Fuera de alcance

- No toco el flujo de paywall ni los planes pagos.
- No cambio la lógica de conteo ya implementada en Supabase.
- El mismo patrón se podrá reutilizar luego en la pantalla de video sin incluirlo aquí.

