# Arreglar selección del segundo item en los scroll pickers verticales

## Problema

Los selectores verticales de estilo (efectos BVT y presets WhatsApp) saltan del primer item al tercero cuando intentas seleccionar el segundo. Esto ocurre porque el scroll automático de iOS genera demasiada velocidad incluso con un gesto mínimo, y los items son muy pequeños (40pt) para que el "snap" funcione bien.

## Solución

Reemplazar el mecanismo de scroll nativo por un sistema de **arrastre manual con snap controlado**, donde nosotros decidimos exactamente a qué item se mueve según la distancia del dedo.

## Cambios

- **Nuevo comportamiento de selección** — En lugar de depender del scroll de iOS para decidir dónde parar, el componente calcula manualmente cuál es el item más cercano al centro basándose en cuánto movió el dedo el usuario
- **Snap preciso** — Al soltar el dedo, el componente se mueve con una animación suave (spring) exactamente al item más cercano, sin importar la velocidad del gesto
- **Mismo aspecto visual** — Se mantiene exactamente el mismo diseño: la máscara de desvanecimiento arriba/abajo, la cápsula de selección, los iconos y textos, y el efecto haptic al cambiar
- **Se aplica a ambos componentes** — Tanto el selector de efectos BVT (lado derecho del canvas) como el selector de presets WhatsApp se actualizan con este nuevo mecanismo
- **Swipe rápido funciona** — Un swipe rápido avanza solo 1 item a la vez (no se salta), garantizando control preciso
