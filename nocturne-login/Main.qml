import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080

    function cfg(key, fallback) {
        var v = config[key]
        return (v === undefined || v === null || String(v) === "") ? fallback : v
    }

    property color baseColor: cfg("baseColor", "#11111b")
    property color panelColor: cfg("panelColor", "#cc11111b")
    property color fieldColor: cfg("fieldColor", "#313244")
    property color borderColor: cfg("borderColor", "#45475a")
    property color accentColor: cfg("accentColor", "#cba6f7")
    property color textColor: cfg("textColor", "#cdd6f4")
    property color mutedColor: cfg("mutedColor", "#9399b2")
    property color dangerColor: cfg("dangerColor", "#f38ba8")
    property date now: new Date()

    color: baseColor

    function tryLogin() {
        errorText.text = ""
        sddm.login(userBox.currentText, passwordField.text, sessionBox.currentIndex)
    }

    Image {
        anchors.fill: parent
        source: root.cfg("background", "backgrounds/default.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#11111b"
        opacity: 0.2
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 72
        anchors.bottomMargin: 72
        spacing: 4

        Text {
            text: Qt.formatTime(root.now, "HH:mm")
            color: root.textColor
            font.pixelSize: 120
            font.weight: Font.Medium
        }
        Text {
            text: Qt.locale().toString(root.now, "dddd, d MMMM")
            color: root.mutedColor
            font.pixelSize: 28
        }
    }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Math.max(380, root.width * 0.26)
        color: root.panelColor

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 80
            spacing: 14

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 96
                Layout.preferredHeight: 96
                radius: 48
                color: root.accentColor

                Text {
                    anchors.centerIn: parent
                    text: userBox.currentText.length > 0 ? userBox.currentText.charAt(0).toUpperCase() : "?"
                    color: root.baseColor
                    font.pixelSize: 44
                    font.weight: Font.Medium
                }
            }

            ThemedCombo {
                id: userBox
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                echoMode: TextInput.Password
                placeholderText: "Contraseña"
                placeholderTextColor: root.mutedColor
                color: root.textColor
                selectionColor: root.accentColor
                font.pixelSize: 16
                leftPadding: 14
                focus: true
                background: Rectangle {
                    radius: 8
                    color: root.fieldColor
                    border.width: 1
                    border.color: passwordField.activeFocus ? root.accentColor : root.borderColor
                }
                Keys.onReturnPressed: root.tryLogin()
                Keys.onEnterPressed: root.tryLogin()
            }

            Text {
                Layout.fillWidth: true
                visible: typeof keyboard !== "undefined" && keyboard.capsLock
                text: "Bloq Mayús activado"
                color: root.mutedColor
                font.pixelSize: 13
            }

            Text {
                id: errorText
                Layout.fillWidth: true
                visible: text.length > 0
                color: root.dangerColor
                font.pixelSize: 14
                wrapMode: Text.WordWrap
            }

            ThemedButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Iniciar sesión"
                primary: true
                onClicked: root.tryLogin()
            }

            ThemedCombo {
                id: sessionBox
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ThemedButton {
                    Layout.fillWidth: true
                    text: "Apagar"
                    visible: sddm.canPowerOff
                    onClicked: sddm.powerOff()
                }
                ThemedButton {
                    Layout.fillWidth: true
                    text: "Reiniciar"
                    visible: sddm.canReboot
                    onClicked: sddm.reboot()
                }
                ThemedButton {
                    Layout.fillWidth: true
                    text: "Suspender"
                    visible: sddm.canSuspend
                    onClicked: sddm.suspend()
                }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Contraseña incorrecta"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorText.text = ""
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
