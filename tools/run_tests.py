#!/usr/bin/env python3
"""Ejecuta varios casos de prueba del tema y resume el resultado. Necesita PySide6.

    python tools/run_tests.py
Las capturas se guardan en build/ (ignorada por git). preview.png se regenera con el caso por defecto.
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, "build")
SCRIPT = os.path.join(ROOT, "tools", "render_preview.py")

CASES = [
    ("defecto-1080p", ["--out", os.path.join(ROOT, "preview.png")]),
    ("dos-sesiones-selector-discreto", ["--sessions", '[["Plasma (Wayland)"],["Plasma (X11)"]]']),
    ("izquierda-1440p-dos-usuarios", ["--size", "2560x1440", "--sessions", '[["Plasma (Wayland)"],["Plasma (X11)"]]',
        "--config", '{"panelSide":"left","showHibernate":"true","accentColor":"#89b4fa","dimBackground":"0.5"}',
        "--users", '[["nancho","Nancho Perez"],["invitado",""]]']),
    ("pantalla-pequena-768p", ["--size", "1366x768"]),
    ("sin-fondo-y-config-rara", ["--allow-missing-image", "--config",
        '{"background":"no-existe.png","panelWidthPercent":"999","dimBackground":"abc","showClock":"false","showUserSelector":"true","panelColor":"#80000000"}']),
    ("login-fallido", ["--fail"]),
    ("sin-botones-ni-sesion", ["--config", '{"showPowerButtons":"false","showSessionSelector":"false"}']),
]


def main():
    os.makedirs(BUILD, exist_ok=True)
    failed = 0
    for name, extra in CASES:
        args = list(extra)
        if "--out" not in args:
            args += ["--out", os.path.join(BUILD, name + ".png")]
        r = subprocess.run([sys.executable, SCRIPT] + args, capture_output=True, text=True)
        status = "OK " if r.returncode == 0 else "FALLO"
        if r.returncode:
            failed += 1
        print(f"[{status}] {name}")
        if r.returncode:
            print((r.stdout + r.stderr).strip())
    print(f"\n{len(CASES) - failed}/{len(CASES)} casos correctos")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
