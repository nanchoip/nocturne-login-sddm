import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: control

    property real scaleUnit: 1
    property color fieldColor: "#313244"
    property color borderColor: "#45475a"
    property color accentColor: "#cba6f7"
    property color textColor: "#cdd6f4"
    property color mutedColor: "#9399b2"

    implicitHeight: 40 * scaleUnit
    font.pixelSize: 15 * scaleUnit

    function labelAt(modelObj, modelDataObj) {
        if (!control.textRole) return modelDataObj
        return Array.isArray(control.model) ? modelDataObj[control.textRole] : modelObj[control.textRole]
    }

    delegate: ItemDelegate {
        width: control.width
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: control.labelAt(model, modelData)
            color: control.textColor
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: highlighted ? control.borderColor : "transparent"
        }
    }

    indicator: Text {
        x: control.width - width - 12 * control.scaleUnit
        y: (control.height - height) / 2
        text: "▾"
        color: control.mutedColor
        font.pixelSize: 14 * control.scaleUnit
    }

    contentItem: Text {
        leftPadding: 12 * control.scaleUnit
        rightPadding: 30 * control.scaleUnit
        text: control.displayText
        color: control.textColor
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 8 * control.scaleUnit
        color: control.fieldColor
        border.width: 1
        border.color: control.activeFocus ? control.accentColor : control.borderColor
    }

    popup: Popup {
        y: control.height + 4 * control.scaleUnit
        width: control.width
        implicitHeight: contentItem.implicitHeight + 2
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
        }

        background: Rectangle {
            radius: 8 * control.scaleUnit
            color: control.fieldColor
            border.width: 1
            border.color: control.borderColor
        }
    }
}
