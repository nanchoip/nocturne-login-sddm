#!/usr/bin/env python3
"""Carga el tema con datos de prueba (sin SDDM) y guarda una captura en preview.png.

Sirve para validar el QML y para regenerar la vista previa. Necesita PySide6:
    pip install PySide6-Essentials
    python tools/render_preview.py
"""
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
                            QTimer, QUrl, Signal, Slot)
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickView

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEME = os.path.join(ROOT, "nocturne-login")


class NameModel(QAbstractListModel):
    """Imita userModel / sessionModel de SDDM: rol 'name' y propiedad lastIndex."""

    def __init__(self, names, parent=None):
        super().__init__(parent)
        self._names = names

    def rowCount(self, parent=QModelIndex()):
        return len(self._names)

    def data(self, index, role=Qt.UserRole + 1):
        return self._names[index.row()] if role == Qt.UserRole + 1 else None

    def roleNames(self):
        return {Qt.UserRole + 1: b"name"}

    @Property(int, constant=True)
    def lastIndex(self):
        return 0

    @Property(int, constant=True)
    def count(self):
        return len(self._names)


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


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "preview.png")
    app = QGuiApplication(sys.argv)
    view = QQuickView()
    view.setResizeMode(QQuickView.SizeRootObjectToView)
    ctx = view.rootContext()
    users = NameModel(["nancho"])
    sessions = NameModel(["Plasma (Wayland)", "Plasma (X11)"])
    sddm = FakeSddm()
    ctx.setContextProperty("config", {})
    ctx.setContextProperty("userModel", users)
    ctx.setContextProperty("sessionModel", sessions)
    ctx.setContextProperty("sddm", sddm)
    ctx.setContextProperty("keyboard", {"capsLock": False})

    errors = []
    view.statusChanged.connect(lambda s: errors.extend(e.toString() for e in view.errors()))
    view.setSource(QUrl.fromLocalFile(os.path.join(THEME, "Main.qml")))
    if view.status() != QQuickView.Ready:
        print("ERROR al cargar el QML:")
        for e in view.errors():
            print("  ", e.toString())
        sys.exit(1)
    view.resize(1920, 1080)
    view.show()

    def grab():
        img = view.grabWindow()
        img.save(out)
        print("preview guardada:", out, img.width(), "x", img.height())
        app.quit()

    QTimer.singleShot(1500, grab)
    app.exec()


if __name__ == "__main__":
    main()
