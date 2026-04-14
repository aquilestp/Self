# Agregar login de desarrollador para revisores de Apple

**Qué se hará:**

- Se añadirá un enlace discreto en la pantalla de login que diga algo como "Developer Access" con tipografía muy pequeña y baja opacidad
- Al tocarlo, aparecerá un mini formulario con campos de email y contraseña
- Las credenciales estarán quemadas en el código (email y password fijos) y se autenticarán contra Supabase usando `signInWithPassword`
- Si las credenciales coinciden, el usuario entra normalmente al dashboard

**Diseño:**

- Un texto muy discreto debajo de los botones de Apple y Google, con opacidad baja (~30%) y tamaño pequeño (caption2)
- Al tocarlo se expande un formulario simple con dos campos y un botón "Sign In"
- El formulario mantiene el mismo estilo oscuro de la pantalla de login
- Visualmente casi invisible para usuarios normales, pero funcional para los revisores de Apple

