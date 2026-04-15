# Eliminar widget "Golden Arch" (primer widget de medalla)

## Cambios

Eliminar completamente el primer widget de medalla ("Golden Arch") de la lista de widgets disponibles.

**Lo que se elimina:**

- El tipo `goldenArch` del catálogo de widgets
- La vista completa del widget Golden Arch y sus helpers
- La miniatura del Golden Arch en el selector de widgets
- La sección de configuración (unidad, pace, tiempo) del Golden Arch en el panel de paleta
- Las propiedades `goldenArchUnitFilter`, `goldenArchShowPace`, `goldenArchShowTime` de la configuración de widgets

**Lo que se conserva:**

- El segundo widget de medalla ("Ancestral") permanece intacto
- Todas las estructuras de soporte compartidas (MedalStarDots, MedalCurvedText, MedalBannerView) se mantienen ya que las usa el Ancestral

