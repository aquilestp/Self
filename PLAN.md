# Límite mensual gratis: 10 imágenes y 2 videos con Self AI


## Qué vamos a construir

Un sistema de cuota gratuita para las generaciones con Self AI (Grok):
- **10 imágenes** generadas al mes, gratis
- **2 videos** generados al mes, gratis
- Ventana móvil de **30 días** desde el primer uso del ciclo (cuando se agota la cuota, el usuario ve cuándo vuelve a tener generaciones disponibles)
- Contador siempre visible en la UI de Self AI
- Paywall (visual, sin pago funcional por ahora) cuando se llega al límite

El scope de esta entrega es **solo la parte gratis y el bloqueo**. El paywall será una pantalla informativa con CTA de "Upgrade" desactivado / "próximamente".

---

## Reglas de conteo

- Cuenta **cada generación exitosa** (imagen o video que se devuelve de Grok), sin importar si el usuario luego la descarta o la lleva al canvas.
- No cuenta si la generación falla por error de red/servidor.
- Imágenes y videos se contabilizan **por separado**, cada uno con su propia cuota.

---

## Dónde se guarda

En **Supabase**, por usuario, para que se sincronice entre dispositivos y no se pueda evadir reinstalando la app. Se crea una tabla nueva que registra cada generación con su tipo y fecha, y se calcula el uso del ciclo actual a partir de ahí.

El ciclo arranca con la primera generación. A los 30 días exactos desde esa primera generación, la cuota se libera.

---

## Experiencia de usuario

### En la pantalla de Self AI (edición de imagen y generación de video)

- Aparece un **indicador compacto de cuota** arriba o cerca del botón de generar:
  - "7 / 10 imágenes este mes" 
  - "1 / 2 videos este mes"
- El indicador cambia de color suave cuando queda 1 uso (tono ámbar) y a rojo cuando está en 0.
- Si queda cuota: el botón de generar funciona normal.
- Si **no queda cuota**: el botón se bloquea visualmente y al tocarlo abre el paywall.

### Paywall (sin pago funcional)

Sheet presentado con el estilo native iOS que ya usa la app:
- Ícono grande (sparkles / corona)
- Título: "Llegaste a tu límite mensual"
- Subtítulo con el detalle:  
  *"Usaste tus 10 imágenes / 2 videos gratis de este mes."*
- **Contador regresivo claro**:  
  *"Tus generaciones gratuitas vuelven en X días"*  
  (calculado desde la primera generación del ciclo + 30 días)
- Lista de beneficios de un futuro plan Pro (placeholder visual):
  - Generaciones ilimitadas
  - Videos en mayor calidad
  - Acceso anticipado a estilos nuevos
- Botón principal **"Upgrade a Pro"** visualmente activo pero que solo muestra un toast/alert: *"Muy pronto"*.
- Botón secundario **"Entendido"** que cierra el sheet.

### Caso sin historial

Si el usuario nunca ha generado nada, el contador muestra *"10 imágenes disponibles"* y *"2 videos disponibles"* sin hablar de ciclo.

---

## Lógica del ciclo de 30 días

- La app consulta al entrar a Self AI las generaciones del usuario en los últimos 30 días.
- Se cuentan cuántas imágenes y cuántos videos hay en esa ventana.
- El "reset" para cada tipo se calcula desde la **generación más antigua dentro de la ventana**: cuando esa generación cumple 30 días, libera un slot.
- El paywall muestra el tiempo que falta para que se libere **el próximo slot** (más útil que esperar al reset total).

Ejemplo: si el usuario generó su imagen #10 hace 5 días, pero la imagen #1 del ciclo fue hace 22 días, el paywall dice: *"Tu próxima imagen gratis vuelve en 8 días"*.

---

## Cambios en la app

### Backend (Supabase)
- Nueva tabla `ai_generations` con: usuario, tipo (image | video), fecha de creación.
- Política RLS para que cada usuario solo lea/escriba sus propias filas.
- Se inserta una fila cada vez que Grok devuelve una generación exitosa.

### Servicios existentes
- `GrokImageEditService` y `GrokVideoService` registrarán el uso después de una generación exitosa, y consultarán la cuota antes de iniciar una generación.
- Si no hay cuota, lanzan un error específico `quotaExceeded` que la UI captura para abrir el paywall en vez de mostrar error genérico.

### UI
- Componente nuevo **QuotaBadge** reusable (imagen / video) visible en la pantalla de Self AI.
- Nueva vista **AIQuotaPaywallView** (sheet) con el diseño descrito.
- Hook en los botones de "Generar" para validar cuota antes de llamar al servicio.

---

## Preguntas que podrían surgir (todas resueltas con defaults razonables)

- El contador se actualiza al abrir la pantalla y después de cada generación.
- No se hace refresh en background; si el usuario deja la app abierta mucho tiempo, se refresca al volver a la pantalla.
- El paywall también es accesible desde un botón "Ver plan Pro" opcional en settings, pero eso lo dejamos para después — por ahora solo aparece al topar el límite.

---

¿Te hace sentido así? Cuando lo apruebes, lo implemento enfocado **solo en lo gratis + el paywall visual**, sin tocar cobros ni planes pagos.
