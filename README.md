# DMS Whisper Plugin

Plugin para Dank Material Shell (dms) que integra reconocimiento de voz mediante Whisper.
Graba audio del micrófono, lo transcribe mediante Whisper, copia el resultado al portapapeles y guarda un respaldo local de las notas.

## Instalación

1. Clona este repositorio en la carpeta de plugins de DMS:
   ```bash
   git clone https://github.com/TU_USUARIO/dms-whisper.git ~/.config/DankMaterialShell/plugins/dms-whisper
   ```
2. Asegúrate de que las dependencias estén instaladas:
   - `arecord` (para grabación de audio)
   - `wl-copy` (para portapapeles en Wayland)
   - CLI de `whisper` (u otra variante de Whisper accesible desde tu `$PATH`)
3. En la interfaz de configuración de DMS (Settings -> Plugins), dale a "Scan" y luego habilita el plugin.
4. Reinicia DMS (`dms restart`).

## Uso

- **Dankbar:** Haz clic en el ícono de micrófono en la barra de tareas para alternar la grabación.
- **IPC / Keybinds:** Puedes configurar un atajo de teclado en tu compositor (Hyprland, Niri, etc.) usando el siguiente comando:
  ```bash
  dms ipc whisper toggle
  ```

## Funciones
- **Interfaz Minimalista:** Un ícono discreto (`mic_none`) que se colorea de rojo (`mic`) al grabar.
- **Portapapeles Automático:** Transcribe usando modelo `base` (en español) y copia el texto al portapapeles.
- **Respaldo en Markdown:** Registra cada dictado de forma secuencial en `~/Documents/WhisperNotes.md`.
