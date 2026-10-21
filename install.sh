#!/usr/bin/env bash
# Copia el tema a la carpeta de temas de SDDM. No toca el gestor de inicio de sesion.
set -euo pipefail

theme="nocturne-login"
here="$(cd "$(dirname "$0")" && pwd)"
dest="/usr/share/sddm/themes"

user_conf="$dest/$theme/theme.conf.user"
keep=""
if [ -f "$user_conf" ]; then
  # Tus ajustes (fondo, colores...) viven en theme.conf.user: se conservan al actualizar el tema
  keep="$(mktemp)"
  sudo cp "$user_conf" "$keep"
fi

sudo mkdir -p "$dest"
sudo rm -rf "${dest:?}/$theme"
sudo cp -r "$here/$theme" "$dest/"

if [ -n "$keep" ]; then
  sudo install -m 644 "$keep" "$user_conf"
  rm -f "$keep"
  echo "Conservado tu theme.conf.user"
fi
echo "Instalado en $dest/$theme"
echo "Prueba:  sddm-greeter-qt6 --test-mode --theme $dest/$theme"
