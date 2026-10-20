#!/usr/bin/env bash
# Copia el tema a la carpeta de temas de SDDM. No toca el gestor de inicio de sesion.
set -euo pipefail

theme="nocturne-login"
here="$(cd "$(dirname "$0")" && pwd)"
dest="/usr/share/sddm/themes"

sudo mkdir -p "$dest"
sudo rm -rf "${dest:?}/$theme"
sudo cp -r "$here/$theme" "$dest/"
echo "Instalado en $dest/$theme"
echo "Prueba:  sddm-greeter-qt6 --test-mode --theme $dest/$theme"
