import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control

    property bool primary: false
    property real scaleUnit: 1
    property color fieldColor: "#313244"
    property color borderColor: "#45475a"
    property color accentColor: "#cba6f7"
    property color accentTextColor: "#11111b"
    property color textColor: "#cdd6f4"

    implicitHeight: 36 * scaleUnit
    font.pixelSize: 14 * scaleUnit

    contentItem: Text {
        text: control.text
        font: control.font
        color: !control.enabled ? Qt.rgba(control.textColor.r, control.textColor.g, control.textColor.b, 0.5)
                                : (control.primary ? control.accentTextColor : control.textColor)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 8 * control.scaleUnit
        opacity: control.enabled ? 1.0 : 0.7
        color: control.primary
               ? (control.down ? Qt.darker(control.accentColor, 1.15)
                               : (control.hovered ? Qt.lighter(control.accentColor, 1.12) : control.accentColor))
               : (control.down ? control.borderColor
                               : (control.hovered ? Qt.lighter(control.fieldColor, 1.2) : control.fieldColor))
        border.width: 1
        border.color: control.activeFocus ? control.accentColor : (control.primary ? control.accentColor : control.borderColor)
    }
}
