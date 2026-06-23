# Bitacora

## 2026-06-22

- Corregido el backend rapido para usar `whisper-ctranslate2` como CLI compatible con faster-whisper.
- Agregado fallback para configuraciones antiguas que todavia apunten a `faster-whisper`.
- Agregado registro de error del ultimo intento en `${XDG_RUNTIME_DIR:-/tmp}/dms-whisper/last-error.log`.
- Actualizada la instalacion de `whisper.cpp` en Arch Linux para usar `yay -S whisper.cpp`.
- Actualizada la documentacion de instalacion para recomendar `pipx install whisper-ctranslate2`.
- Ampliado `.gitignore` para excluir artefactos locales de audio, transcripcion, logs y editor.
- Documentada la dependencia `ffmpeg` (necesaria por los backends `openai-whisper` y `whisper-ctranslate2` para decodificar el audio) en las tres distros del README.
- README de Arch ahora recomienda `pacman -S whisper-cpp-vulkan` (binario prebuilt en repos CachyOS, acelerado por Vulkan) en vez de compilar `yay -S whisper.cpp`.
- Descargado modelo `ggml-base.bin` en `~/.local/share/whisper.cpp/` para el backend whisper.cpp.
