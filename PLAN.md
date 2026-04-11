# Efectos visuales para el stat "Blurred Vertical"

## Descripción
Agregar un sistema de efectos visuales al stat "Blurred Vertical" con 5 opciones de efecto, controlable desde la paleta flotante. Por defecto, el stat se agrega con el efecto **Blur de fondo**.

---

## Efectos disponibles
1. **None** — Texto plano, sin efecto (como está ahora)
2. **Blur** *(por defecto)* — Un rectángulo difuminado semi-transparente detrás del bloque de texto, dándole profundidad y legibilidad sobre la foto
3. **Glow** — Resplandor suave alrededor de cada línea de texto, usando el color del widget
4. **Stroke** — Contorno/outline alrededor de las letras en un color contrastante (negro si el texto es claro, blanco si es oscuro)
5. **Gradient** — El texto se rellena con un degradado vertical usando el color del widget y una versión más clara/oscura

---

## Diseño del control en la paleta
- Un nuevo botón circular en la paleta flotante (al inicio, antes de las unidades)
- Muestra un ícono representando el efecto activo (sparkles, blur, glow, etc.)
- Cada tap cicla al siguiente efecto: None → Blur → Glow → Stroke → Gradient → None...
- Se anima suavemente como los demás botones de la paleta

---

## Comportamiento
- Al agregar el stat desde el drawer, viene con efecto **Blur** preseleccionado
- El efecto se aplica a todo el bloque de texto del stat
- El efecto respeta el color elegido del widget
- Los efectos se guardan por widget individual (cada stat puede tener su propio efecto)
