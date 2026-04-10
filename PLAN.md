# Unificar toggles KM/MI en un solo botón

## Cambio

Reemplazar todos los pares de botones KM / MI por **un único botón toggle** que alterna entre ambos al hacer tap. Por defecto siempre muestra **KM**.

---

### **Qué cambia**

- Se crea un componente único reutilizable: un botón circular que muestra "KM" o "MI" y cambia al hacer tap
- Se usa en **5 secciones** del editor que usan la unidad KM/MI:
  - Splits
  - Distance Words
  - Basic Unit (los 6 stats principales del drawer)
  - Full Banner
  - Full Banner Bottom
- Se mantiene el mismo estilo visual (círculo con borde, texto bold, animación spring)
- **Best Efforts se mantiene igual** porque tiene 3 opciones (KM, MI, Both) — reducirlo a un toggle rompería funcionalidad

### **Cómo funciona**

- Un solo botón circular que muestra el estado actual ("KM" o "MI")
- Al hacer tap, alterna al otro valor con animación
- Haptic feedback al cambiar
- Valor por defecto: **KM**

### **Diseño**

- Mismo tamaño y estilo que los botones actuales (36×36, texto 12pt bold)
- Siempre muestra el estado activo (fondo claro, borde visible)
- Transición suave al cambiar el texto
