# Fix null "type" column error

## Análisis

**Lo que envía la app (correcto, no tocar):**
- `user_id` → string UUID
- `kind` → `"image"` o `"video"`

**Lo que tiene la tabla actualmente:**
- Columna `type` (NOT NULL) — el app no envía `type`, envía `kind` → null → error

## Plan (solo cambios en Supabase, no en el app)

- [ ] En Supabase → Table Editor → `ai_generations` → renombrar la columna `type` a `kind`

  Esto se puede hacer con este SQL en el SQL Editor de Supabase:
  ```sql
  ALTER TABLE ai_generations RENAME COLUMN "type" TO kind;
  ```

Eso es todo. El app ya envía `kind` correctamente, solo la columna tiene el nombre incorrecto.
