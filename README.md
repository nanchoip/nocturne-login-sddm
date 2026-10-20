# Nocturne Login (tema para SDDM)

Pantalla de inicio de sesion oscura para **SDDM con Qt 6**: reloj grande a la izquierda y panel lateral
translucido a la derecha con usuario, contrasena, sesion y botones de apagado.
Usa la paleta Catppuccin Mocha. Es un diseno independiente, escrito desde cero (no deriva de otros temas)
y no es un proyecto oficial de Catppuccin.

![Vista previa](preview.png)

*Captura generada cargando el propio QML con datos de prueba (`tools/render_preview.py`). La tipografia
depende de tu sistema; en la captura es una fuente de Windows.*

## Importante: solo para SDDM

Este tema **no funciona con Plasma Login Manager**, el gestor nuevo que usan algunas versiones recientes
de Fedora KDE, porque ese gestor no admite temas QML propios. Comprueba cual tienes:

```bash
systemctl status display-manager --no-pager | head -n 5
```

Si ves `plasmalogin.service`, necesitas cambiar a SDDM antes de poder usar este tema (ver abajo).

## Instalacion

```bash
git clone https://github.com/nanchoip/nocturne-login-sddm.git
cd nocturne-login-sddm
./install.sh
```

El script solo copia el tema a `/usr/share/sddm/themes/nocturne-login`. No cambia el gestor de inicio de sesion.

### Probarlo sin cerrar sesion

Hace falta tener SDDM instalado (`sudo dnf install sddm qt6-qtsvg qt6-qtmultimedia`), aunque no este activado:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/nocturne-login
```

Si algo falla, los errores de QML salen en esa terminal.

### Activarlo (si SDDM es tu gestor)

```bash
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=nocturne-login\n' | sudo tee /etc/sddm.conf.d/10-nocturne.conf
```

Rescate si algo sale mal: `Ctrl + Alt + F3`, inicia sesion y ejecuta
`sudo rm /etc/sddm.conf.d/10-nocturne.conf && sudo reboot`.

## Personalizar

No edites el tema directamente: crea `/usr/share/sddm/themes/nocturne-login/theme.conf.user` con solo lo que quieras
cambiar, por ejemplo tu propio fondo y otro color de acento:

```ini
[General]
background=/usr/share/backgrounds/mi-fondo.jpg
accentColor=#89b4fa
```

Valores disponibles: `background`, `baseColor`, `panelColor`, `fieldColor`, `borderColor`, `accentColor`,
`textColor`, `mutedColor`, `dangerColor` (ver `theme.conf`).

## Estado

- El QML se valida cargandolo con PySide6 y datos de prueba; **todavia no se ha probado dentro de SDDM real**.
  Si encuentras errores, abre una issue con la salida del modo de prueba.
- Pendiente: avatar del usuario, teclado virtual y traducciones.

## Regenerar el fondo y la vista previa

```bash
pip install pillow PySide6-Essentials
python tools/make_background.py
python tools/render_preview.py
```

## Licencia

MIT. Ver [LICENSE](LICENSE).
