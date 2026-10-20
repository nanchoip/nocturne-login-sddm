import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: control
    implicitHeight: 40
    font.pixelSize: 15

    delegate: ItemDelegate {
        width: control.width
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: model[control.textRole]
            color: "#cdd6f4"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: highlighted ? "#45475a" : "transparent"
        }
    }

    indicator: Text {
        x: control.width - width - 12
        y: (control.height - height) / 2
        text: "▾"
        color: "#9399b2"
        font.pixelSize: 14
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: 30
        text: control.displayText
        color: "#cdd6f4"
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 8
        color: "#313244"
        border.width: 1
        border.color: control.activeFocus ? "#cba6f7" : "#45475a"
    }

    popup: Popup {
        y: control.height + 4
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
            radius: 8
            color: "#313244"
            border.width: 1
            border.color: "#45475a"
        }
    }
}
