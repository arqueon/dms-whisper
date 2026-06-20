# Dank Material Shell (DMS) Whisper Plugin

Un plugin para [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell) que integra el poder de transcripción de IA de **Whisper** directamente en tu barra de tareas.

Te permite grabar notas de voz con un clic (o mediante atajos de teclado IPC), transcribe el audio en segundo plano usando Whisper, copia el texto resultante a tu portapapeles y guarda un respaldo tanto del audio como de la nota de texto.

## Características

- **Diseño Minimalista**: Un ícono de micrófono (`mic_none`) que se torna de color rojo (`mic`) al grabar, mezclándose perfectamente con el tema de DMS.
- **Flujo de Trabajo Silencioso**: Te avisa del inicio de grabación y el éxito de transcripción mediante notificaciones nativas de sistema.
- **Control por IPC**: Puede integrarse fácilmente en tu gestor de ventanas (Hyprland, Niri, Sway, etc.) mediante atajos de teclado.
- **Historial Organizado**: Crea archivos de audio y texto separados con marcas de tiempo exactas, y mantiene un *log* cronológico centralizado.

---

## Requisitos y Dependencias

Antes de instalar el plugin, necesitas asegurarte de tener en el sistema las utilidades de grabación, manejo de portapapeles y el propio motor de Whisper.

En distribuciones basadas en **Arch Linux** (como CachyOS, EndeavourOS, etc):

1. **Instalar utilidades del sistema:**
   ```bash
   sudo pacman -S alsa-utils wl-clipboard
   ```
   *(Nota: `alsa-utils` incluye la herramienta `arecord`, y `wl-clipboard` incluye `wl-copy`)*

2. **Instalar Whisper (OpenAI):**
   La forma más limpia es mediante `pipx` para que el ejecutable `whisper` esté disponible globalmente de manera aislada sin entrar en conflictos de dependencias en el sistema:
   ```bash
   sudo pacman -S python-pipx
   pipx install openai-whisper
   ```
   *(Asegúrate de que `~/.local/bin` esté en tu variable de entorno `$PATH`)*

---

## Instalación del Plugin

1. Clona este repositorio dentro de la carpeta de plugins de tu configuración local de Dank Material Shell:
   ```bash
   git clone https://github.com/arqueon/dms-whisper.git ~/.config/DankMaterialShell/plugins/dms-whisper
   ```
   
2. Otorga permisos de ejecución al script principal:
   ```bash
   chmod +x ~/.config/DankMaterialShell/plugins/dms-whisper/whisper-action.sh
   ```

3. Abre las preferencias de Dank Material Shell (usualmente presionando `Mod + ,`), ve a la pestaña **Plugins**, haz clic en el botón de **Scan** y habilita el plugin llamado **Whisper Voice Rec.**

4. Para que el plugin y su componente IPC carguen por primera vez de forma íntegra, reinicia el entorno DMS:
   ```bash
   dms restart
   ```

---

## Uso

### Desde la Interfaz Gráfica (Dankbar)
Simplemente haz clic izquierdo en el icono de micrófono ubicado en tu panel superior o vertical. El icono cambiará y se pintará de rojo para indicar que la grabación está activa. Vuelve a hacer clic para detener la captura y dar paso a la transcripción automática.

### Mediante Comandos IPC (Atajos de teclado)
El plugin registra un comando en el bus IPC de Dank Material Shell que te permite alternar el estado (empezar/detener) sin depender de clics. 

Puedes configurar este comando en el archivo de tu compositor (por ejemplo, en `hyprland.conf`):

```bash
# Asignar a la combinación de teclas SUPER + W
bind = SUPER, W, exec, dms ipc whisper toggle
```

### ¿Dónde se guardan mis notas y audios?
El plugin ha sido configurado para organizar automáticamente todo en tu carpeta de Documentos:
- **Directorio base:** `~/Documents/Whisper/`
- **Audio original guardado:** `Whisper_YYYY-MM-DD_HH-MM-SS.wav`
- **Texto crudo extraído:** `Whisper_YYYY-MM-DD_HH-MM-SS.txt`
- **Registro Global (El Log):** `WhisperNotes.md`. Este es un archivo vivo en donde se van agregando todas tus transcripciones secuencialmente en formato *bullet-points* con fecha y hora.

---

## Personalización Avanzada
Si deseas cambiar el modelo por defecto (el plugin utiliza el modelo `base` adaptado a idioma español) o su ruta de guardado, puedes editar las siguientes variables abriendo el archivo `whisper-action.sh`:

```bash
OUT_DIR="$HOME/Documents/Whisper"
# ...
whisper "$AUDIO_FILE" --model base --language es --output_format txt --output_dir "$OUT_DIR" >/dev/null 2>&1
```

*(Los modelos disponibles en OpenAI Whisper por orden de precisión/peso son: `tiny`, `base`, `small`, `medium`, `large`)*
