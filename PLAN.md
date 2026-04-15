# Cambiar color de títulos de indicadores a color principal del widget

## Resumen

Todos los títulos de indicadores (como PACE, DIST, TIME, ELEVATION, MOVING, ELAPSED, AVG HR, BPM, KMs THIS WEEK, BEST EFFORTS, etc.) cambiarán de su color semi-transparente actual al mismo color principal del widget (blanco por defecto). Esto aplica tanto en el drawer como en el canvas.

## Cambios en widgets del canvas

- **Distance, DistPace, ThreeStats**: Los labels como "DIST", "PACE", "TIME" pasarán de color secundario/terciario a color principal
- **Stack**: Los labels de cada fila pasarán a color principal
- **Hero Stat**: "PACE" y "TIME" pasarán a color principal
- **Wide**: El label superior pasará a color principal
- **Full Banner / Full Banner Bottom**: Los labels "TIME", "DIST", "MIN/KM", "ELEV" pasarán a color principal
- **Moving Time / Elapsed Time**: "MOVING" y "ELAPSED" pasarán a color principal
- **Avg Heart Rate / HR Pulse Dots**: "AVG HR" y "BPM" pasarán a color principal
- **Elevation Gain**: "ELEVATION GAIN" pasará a color principal
- **Weekly/Monthly KM widgets**: "KMs THIS WEEK", "KMs LAST WEEK", etc. pasarán a color principal
- **Best Efforts**: "BEST EFFORTS" pasará a color principal
- **Distance Words**: El label de unidad pasará a color principal
- **City Activity**: Los labels "Distance", "Pace", "Time" pasarán a color principal
- **Helpers compartidos** (`topRowStatColumn`, `statColumn`): Labels pasarán a color principal

## Cambios en mini previews del drawer

- Todos los labels de indicadores que usan `.white.opacity(0.4)` o `.white.opacity(0.45)` pasarán a `.white`
- Esto incluye: miniStat, distance preview, distPace preview, miniTimeArcClean, miniFullBanner, miniFullBannerBottom, miniElevationGain, miniSplits, miniSplitsTable, miniSplitsBars, miniSplitsFastest, miniBestEfforts, miniDistanceWords, miniHRPulseDots, y todos los demás mini widgets con títulos de indicadores

