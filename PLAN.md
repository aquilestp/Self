# Arreglar generación de video con Grok Imagine + prompts predefinidos

## Problema identificado

Según la documentación oficial de xAI, el API de image-to-video espera la imagen así:

```
{ "image": { "url": "https://..." } }
```

Tu Edge Function probablemente recibe `image_url` del iOS y no lo transforma correctamente al formato que xAI espera. Además, el polling debe hacerse a `GET /v1/videos/{request_id}` y la respuesta viene como `video.url` (no `video_url`).

---

## Cambios propuestos

### 1. Edge Function `grok-video-generate` (Supabase)

Te daré el código correcto del Edge Function que:

- Recibe `image_url` y `prompt` del iOS
- Transforma al formato correcto de xAI: `{ model: "grok-imagine-video", prompt, image: { url }, duration, resolution }`
- En POST: envía la solicitud a `https://api.x.ai/v1/videos/generations` y retorna el `request_id`
- En GET: hace polling a `https://api.x.ai/v1/videos/{request_id}` y retorna `{ status, video_url }`

### 2. Tabla `video_style_prompts` en Supabase

Crear una tabla similar a `edit_style_prompts` con:

- `id`, `style_key`, `prompt_template`, `is_active`, `display_name`, `icon` (opcional)
- Ejemplo de prompt: *"Cinematic slow zoom, subtle movement, dramatic lighting"*

### 3. iOS — Nuevo modelo `VideoStylePrompt`

Un modelo para los prompts de video predefinidos desde Supabase.

### 4. iOS — Actualizar `GrokVideoService`

- Agregar método para cargar prompts de video desde Supabase (`video_style_prompts`)
- Enviar el `prompt` junto con `image_url` al Edge Function
- Mantener compatibilidad: si no hay prompt, el video se genera solo desde la imagen

### 5. iOS — Actualizar `VideoGenerationView`

- Antes de generar, mostrar un selector de estilo/prompt (similar al drawer de edición de imagen)
- Opciones predefinidas desde Supabase + opción de "sin prompt" (animación automática)
- El flujo: seleccionar estilo → generar → polling → resultado

### 6. iOS — Actualizar `EditorAIOverlays`

- Pasar el prompt seleccionado al flujo de generación de video

