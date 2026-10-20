import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    property bool primary: false

    implicitHeight: 36
    font.pixelSize: 14

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.primary ? "#11111b" : "#cdd6f4"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 8
        color: control.primary
               ? (control.down ? "#b690e6" : (control.hovered ? "#d7b6fa" : "#cba6f7"))
               : (control.down ? "#45475a" : (control.hovered ? "#3b3d52" : "#313244"))
        border.width: 1
        border.color: control.activeFocus ? "#cba6f7" : (control.primary ? "#cba6f7" : "#45475a")
    }
}
