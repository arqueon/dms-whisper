# Bitacora

## 2026-06-22

- Corregido el backend rapido para usar `whisper-ctranslate2` como CLI compatible con faster-whisper.
- Agregado fallback para configuraciones antiguas que todavia apunten a `faster-whisper`.
- Agregado registro de error del ultimo intento en `${XDG_RUNTIME_DIR:-/tmp}/dms-whisper/last-error.log`.
- Actualizada la instalacion de `whisper.cpp` en Arch Linux para usar `yay -S whisper.cpp`.
- Actualizada la documentacion de instalacion para recomendar `pipx install whisper-ctranslate2`.
- Ampliado `.gitignore` para excluir artefactos locales de audio, transcripcion, logs y editor.
