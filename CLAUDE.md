# Encuesta "¿Qué auto va contigo?"

Encuesta móvil que se abre desde un QR impreso en revista. Perfila al cliente de
un negocio de **seminuevos multimarca** y guarda la respuesta como lead en Supabase.

## Stack
- Un solo `index.html` estático (HTML/CSS/JS vanilla, sin build). El generador de QR
  (qrcode-generator 1.4.4) va **inline** dentro de `index.html`; no hay archivos JS aparte.
- `aviso-de-privacidad.html` se sirve en `/aviso-de-privacidad` (cleanUrls en `vercel.json`).
- Hosting: Vercel, proyecto `encuesta-auto` → https://encuesta-auto.vercel.app (push a `main` despliega).
- Datos: Supabase, tabla `encuestas_auto` (ver `schema.sql`). RLS: el rol `anon` SOLO puede INSERT.

## Reglas
- En cada cambio a `index.html`, subir `CONFIG.APP_BUILD` (formato `AAAA.MM.DD-N`) y
  terminar con los comandos de git listos.
- `node --check` sobre el script de `index.html` antes de dar algo por terminado.
- Nunca `git add .`: agregar los archivos por nombre.
- `SUPABASE_URL` es solo el dominio (`https://xxxx.supabase.co`), sin `/rest/v1`.
- La anon key es pública por diseño. Nunca poner la `service_role` en este repo.
- El QR impreso apunta a `https://encuesta-auto.vercel.app/?src=revista`. **No cambiar el
  dominio ni la ruta raíz**: el QR de la revista ya no se puede reimprimir.
- Los nombres de archivo van en minúsculas (Vercel distingue mayúsculas; Windows no).

## Lógica de perfiles
- 6 perfiles: urb, fam, tra, dep, pre, tec. Cada opción suma puntos (`w`) y el % se
  normaliza contra el máximo posible de cada perfil (`MAX`).
- `cuando` y `pago` no puntúan: califican el lead (`temperatura` caliente/tibio/frío).
- Si se agrega o cambia una pregunta, verificar que los 6 perfiles sigan saliendo
  diferenciados con un juego de respuestas típico de cada uno.

## Pendientes
- `BRAND` todavía dice "Tu agencia".
- Aviso de privacidad: llenar los `[CORCHETES]`; agregar razón social cuando exista.
