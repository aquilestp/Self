# Rediseñar fondo del panel de estilos lateral

**Cambios:**

1. **Eliminar los dos fondos sólidos actuales:**
  - El fondo principal del panel (`PaletteSelectorView`) que tiene material + gradiente blanco
  - El fondo oscuro sólido del picker de fonts/efectos (`BVTEffectScrollPicker` y `SplitBannerFontScrollPicker`)
2. **Nuevo fondo único sutil:**
  - Un solo fondo que cubre toda la altura del panel de controles
  - Casi completamente transparente hacia la izquierda (centro de la pantalla)
  - Ligeramente visible hacia la derecha (borde de la pantalla)
  - Sin bordes redondeados en el lado derecho (pegado al borde)
  - Bordes redondeados solo en el lado izquierdo
  - Efecto de gradiente muy sutil usando solo opacidad mínima, sin material grueso

