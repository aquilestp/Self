# Eliminar botón "Edit" del widget de WhatsApp

**Cambio:**
- Se eliminará el botón "Edit" que aparece debajo del selector de mensajes de WhatsApp en el editor de fotos
- Los usuarios solo podrán elegir entre los mensajes predefinidos del scroll picker, sin opción de escribir un mensaje personalizado

**Archivos afectados:**
- El componente del scroll picker de WhatsApp — se elimina el botón "Edit" y la propiedad `onEditTapped`
- La vista del editor de fotos — se elimina la lógica del alert "Edit Message" y las variables relacionadas (`showWhatsappTextEdit`, `whatsappEditingText`)
- Se limpia el parámetro `onEditTapped` donde se usa el picker
