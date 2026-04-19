# Unificar tamaño y centrado de los widgets en el drawer

**Qué cambia (solo drawer, no el canva):**

- Cada tarjeta del drawer mostrará su vista previa ocupando ~65–70% del alto/ancho de la tarjeta, siempre centrada vertical y horizontalmente.
- Los widgets más pequeños (como los de tipografía pequeña) se agrandarán uniformemente aplicando un escalado coherente, para que se vean igual de presentes que los más grandes.
- Los widgets que hoy se ven desproporcionadamente grandes o pegados a un borde se centrarán y se ajustarán al mismo marco interno.
- Se respeta el recorte de cada tarjeta: ningún contenido podrá desbordarse por los lados (se mantiene el clip redondeado existente).
- No se toca el orden (sorting) del drawer ni el comportamiento de las versiones compacta/expandida.
- Los banners de ancho completo (full banner) conservan su layout pero también quedan centrados dentro de su marco.

**Cómo se logra visualmente:**

- La vista previa de cada widget se envuelve en un contenedor de tamaño fijo proporcional a la tarjeta (~70% de su área útil), con centrado en ambos ejes.
- Se aplica un leve escalado uniforme cuando el contenido natural es más pequeño que ese marco, para que todos se vean con un peso visual similar.
- Clip aplicado al contenedor interno para que ningún contenido sobresalga de la tarjeta, incluso con nombres o valores largos.

**Resultado esperado:**

- Grid del drawer se siente más uniforme, con cada preview claramente visible y centrado.
- Previews pequeñas ya no parecerán “perdidas” en la esquina; las grandes ya no tocarán los bordes.

