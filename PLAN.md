# Cambiar fuentes de los stats a .serif del sistema

**Cambio**

- Reemplazar todas las fuentes custom `InstrumentSerif-Regular` e `InstrumentSerif-Italic` por la fuente del sistema con diseño `.serif` en los dos stats (distancia y pace)
- Aplicar el cambio tanto en el **editor/canvas** (archivo `DraggableStatWidget.swift`) como en el **drawer** (archivo `EditorMiniPreviews.swift`)
- Mantener el estilo elongado vertical tal como está actualmente
- Los tamaños, pesos y demás propiedades visuales se mantienen idénticos — solo cambia la familia tipográfica