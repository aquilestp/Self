# Split Banner: fuente Condensed Extra Bold Italic expanded + selector de SpecialFonts


**Cambios:**

1. **Fuente por defecto del Split Banner** — Cambiar la fuente del widget (canvas y drawer) de `.system rounded black italic` a **sistema Condensed Extra Bold Italic con width expanded** (`.system(size:19, weight:.heavy).italic().width(.expanded)`)

2. **Nuevo enum `SplitBannerFontStyle`** — Un enum con las opciones:
   - **System** (default) — Condensed Extra Bold Italic expanded
   - **MetalMania**
   - **Monofett**
   - **NewRocker**
   - **Rubik80sFade**
   - **RubikDistressed**
   - **RubikGlitch**
   - **SedgwickAve**
   - **Sekuya**
   - **SixCaps**

3. **Nueva propiedad `splitBannerFontStyle`** — Añadida a `PlacedWidget`, `StatWidgetContentView`, y toda la cadena de parámetros (equatable, constructores del canvas y export)

4. **VerticalSnapPicker en el editor** — Cuando el Split Banner esté seleccionado, aparecerá un picker vertical (igual al de WhatsApp/BVT) debajo del botón de unidad, permitiendo cambiar entre los estilos de SpecialFonts

5. **Drawer mini preview** — La mini vista del Split Banner también usará la fuente Condensed Extra Bold Italic expanded por defecto
