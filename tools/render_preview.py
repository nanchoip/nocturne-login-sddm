#!/usr/bin/env python3
"""Carga el tema con datos de prueba (sin SDDM), captura la pantalla y avisa de cualquier error de QML.

Necesita PySide6:  pip install PySide6-Essentials

Ejemplos:
    python tools/render_preview.py                       # genera preview.png
    python tools/render_preview.py --size 2560x1440 --config '{"panelSide":"left"}' --out /tmp/a.png
    python tools/render_preview.py --fail                # simula una contrasena incorrecta
Codigo de salida: 0 = correcto, 1 = no carga, 2 = cargo con avisos o errores de QML.
"""
import argparse
import json
import os
import sys

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
# El modo offscreen no trae fuentes propias: apuntamos a las del sistema.
for _fonts in (r"C:\Windows\Fonts", "/usr/share/fonts"):
    if os.path.isdir(_fonts):
        os.environ.setdefault("QT_QPA_FONTDIR", _fonts)
        break

from PySide6.QtCore import (Property, QAbstractListModel, QModelIndex, QObject, Qt,
                            QTimer, QUrl, Signal, Slot, qInstallMessageHandler)
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickView

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEME = os.path.join(ROOT, "nocturne-login")
messages = []


class UserModel(QAbstractListModel):
    """Imita userModel / sessionModel de SDDM: roles name (+1) y realName (+2), lastIndex y count."""

    def __init__(self, rows, parent=None):
        super().__init__(parent)
        self._rows = rows

    def rowCount(self, parent=QModelIndex()):
        return len(self._rows)

    def data(self, index, role=Qt.UserRole + 1):
        if not index.isValid():
            return None
        row = self._rows[index.row()]
        if role == Qt.UserRole + 1:
            return row[0]
        if role == Qt.UserRole + 2:
            return row[1] if len(row) > 1 else ""
        return None

    def roleNames(self):
        return {Qt.UserRole + 1: b"name", Qt.UserRole + 2: b"realName"}

    @Property(int, constant=True)
    def lastIndex(self):
        return 0

    @Property(int, constant=True)
    def count(self):
        return len(self._rows)


class FakeSddm(QObject):
    loginFailed = Signal()
    loginSucceeded = Signal()

    @Property(bool, constant=True)
    def canPowerOff(self):
        return True

    @Property(bool, constant=True)
    def canReboot(self):
        return True

    @Property(bool, constant=True)
    def canSuspend(self):
        return True

    @Property(bool, constant=True)
    def canHibernate(self):
        return True

    @Slot(str, str, int)
    def login(self, user, password, session):
        pass

    @Slot()
    def powerOff(self):
        pass

    @Slot()
    def reboot(self):
        pass

    @Slot()
    def suspend(self):
        pass

    @Slot()
    def hibernate(self):
        pass


def handler(mode, context, message):
    messages.append(message)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(ROOT, "preview.png"))
    ap.add_argument("--size", default="1920x1080")
    ap.add_argument("--config", default="{}", help="JSON con valores de theme.conf")
    ap.add_argument("--users", default='[["nancho","Nancho"]]', help="JSON: lista de [usuario, nombre real]")
    ap.add_argument("--fail", action="store_true", help="simula login fallido antes de capturar")
    ap.add_argument("--allow-missing-image", action="store_true",
                    help="no tratar como error que falte la imagen de fondo (caso de prueba)")
    args = ap.parse_args()
    w, h = (int(x) for x in args.size.lower().split("x"))

    qInstallMessageHandler(handler)
    app = QGuiApplication(sys.argv[:1])
    view = QQuickView()
    view.setResizeMode(QQuickView.SizeRootObjectToView)
    ctx = view.rootContext()
    users = UserModel(json.loads(args.users))
    sessions = UserModel([["Plasma (Wayland)"], ["Plasma (X11)"]])
    sddm = FakeSddm()
    ctx.setContextProperty("config", json.loads(args.config))
    ctx.setContextProperty("userModel", users)
    ctx.setContextProperty("sessionModel", sessions)
    ctx.setContextProperty("sddm", sddm)
    ctx.setContextProperty("keyboard", {"capsLock": False})

    view.setSource(QUrl.fromLocalFile(os.path.join(THEME, "Main.qml")))
    if view.status() != QQuickView.Ready:
        print("ERROR al cargar el QML:")
        for e in view.errors():
            print("  ", e.toString())
        sys.exit(1)
    view.resize(w, h)
    view.show()

    if args.fail:
        QTimer.singleShot(500, sddm.loginFailed.emit)

    def grab():
        img = view.grabWindow()
        img.save(args.out)
        print(f"captura: {args.out} {img.width()}x{img.height()}")
        app.quit()

    QTimer.singleShot(1500, grab)
    app.exec()

    problems = [m for m in messages if "qml" in m.lower() or "Error" in m or "Cannot" in m]
    if args.allow_missing_image:
        problems = [m for m in problems if "QQuickImage: Cannot open" not in m]
    for m in problems:
        print("AVISO:", m)
    sys.exit(2 if problems else 0)


if __name__ == "__main__":
    main()
