# Agregar fondo al scroll de estilos de fuente

## Cambio

Añadir un fondo oscuro semi-transparente detrás del scroll picker de estilos de fuente (`SplitBannerFontScrollPicker`) para que sea legible sobre cualquier fondo de foto.

## Diseño

- Fondo de material frosted glass oscuro (`.ultraThinMaterial` + capa negra al 40%) aplicado al contenedor del scroll
- Bordes redondeados suaves con una línea sutil blanca al 10%
- El mismo tratamiento se aplica también a `BVTEffectScrollPicker` para consistencia visual

