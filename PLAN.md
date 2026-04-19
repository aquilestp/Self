# Arreglar widgets del drawer que se salen de los cards

## Problema

En el drawer de widgets, varios cards muestran su contenido desbordado por fuera de los bordes del card: los horizontales (Morning Run, 9.1 KM, DIST/PACE, títulos grandes, nine point one, banners) se salen por la derecha y/o izquierda; otros como "notes/orning Run" quedan cortados horrible.

La causa: el contenido se agranda con un factor de escala grande dentro de un card de ancho fijo, pero la escala en SwiftUI no reduce el tamaño de layout — el contenido se dibuja por fuera del card y no se recorta correctamente.

## Qué voy a corregir

- **Recortar correctamente cada card del drawer** para que nada se salga del borde, sin importar qué widget sea.
- **Ajustar el tamaño del contenido de cada widget** para que quepa dentro del card de forma proporcional y quede centrado, ocupando aprox el 60–75% del card como ya habíamos definido.
- **Revisar uno a uno los widgets problemáticos**:
  - Morning Run / Title card (texto ancho expandido)
  - 9.1 KM gigante (bold / impact / poster / wide / tower / heroStat)
  - DIST · PACE horizontal
  - nine point one (distanceWords)
  - Full banner (4 stats horizontales)
  - notesScreenshot (la captura blanca que se sale)
  - whatsappMessage (burbuja que se corta)
  - Splits fastest / splits bars / splits table (filas con tiempos que se cortan)
- **Mantener el sorting actual** (popular/recents) sin tocarlo.
- **Mantener fondo translúcido oscuro** y estilo visual ya acordado.

## Resultado esperado

Todos los cards del drawer (tanto en vista pequeña como expandida) muestran su contenido **completo, centrado y contenido dentro del card**, sin desbordes, sin cortes feos, con tamaño consistente y legible.