# Transición de swipe fluida en el onboarding

## Problema

El onboarding solo detecta el swipe cuando el dedo se levanta, por eso se siente "pegado". No hay retroalimentación visual mientras el usuario arrastra.

## Solución

Hacer que el contenido **siga el dedo en tiempo real** y al soltar se deslice naturalmente al paso siguiente/anterior, o rebote de vuelta si el swipe fue muy corto.

## Cambios

**Seguimiento en tiempo real del dedo**

- Mientras el usuario arrastra, el contenido se desplaza horizontalmente siguiendo el dedo con una resistencia suave (efecto "rubber band")
- El paso actual se desliza hacia afuera y el paso siguiente asoma desde el borde

**Snap al soltar**

- Si el swipe supera un umbral (~100pt) o tiene velocidad suficiente → avanza o retrocede al siguiente paso con animación spring
- Si el swipe es muy corto → rebota de vuelta a la posición original con spring

**Transición de slide en vez de fade**

- Los pasos se deslizan horizontalmente entre sí (slide left/right) en lugar del actual fade+scale que no comunica dirección
- Mantiene el estilo visual actual (fondo, botones, progress dots) sin cambios de diseño

**Botón CTA sin cambios**

- El botón "Next" / "Continue" sigue funcionando igual con su animación snappy actual

