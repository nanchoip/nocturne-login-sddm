import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: baseColor

    // ---- configuracion (theme.conf / theme.conf.user) ----
    function cfg(key, fallback) {
        var v = config[key]
        return (v === undefined || v === null || String(v) === "") ? fallback : v
    }
    function cfgBool(key, fallback) {
        var v = String(cfg(key, fallback ? "true" : "false")).toLowerCase()
        return v === "true" || v === "1" || v === "yes"
    }
    function cfgNum(key, fallback, min, max) {
        var n = parseFloat(cfg(key, fallback))
        if (isNaN(n)) n = fallback
        return Math.max(min, Math.min(max, n))
    }

    property color baseColor: cfg("baseColor", "#11111b")
    property color panelColor: cfg("panelColor", "#cc11111b")
    property color fieldColor: cfg("fieldColor", "#313244")
    property color borderColor: cfg("borderColor", "#45475a")
    property color accentColor: cfg("accentColor", "#cba6f7")
    property color accentTextColor: cfg("accentTextColor", "#11111b")
    property color textColor: cfg("textColor", "#cdd6f4")
    property color mutedColor: cfg("mutedColor", "#9399b2")
    property color dangerColor: cfg("dangerColor", "#f38ba8")

    readonly property bool panelOnRight: String(cfg("panelSide", "right")).toLowerCase() !== "left"
    readonly property real panelPercent: cfgNum("panelWidthPercent", 26, 18, 60)
    readonly property real dim: cfgNum("dimBackground", 0.2, 0, 1)
    readonly property string clockFormat: String(cfg("clockFormat", "HH:mm"))
    readonly property string dateFormat: String(cfg("dateFormat", "dddd, d MMMM"))
    readonly property bool showClock: cfgBool("showClock", true)
    readonly property string sessionSelectorMode: String(cfg("showSessionSelector", "auto")).toLowerCase()
    readonly property bool showSessionSelector: sessionSelectorMode === "true"
                                                || (sessionSelectorMode !== "false" && sessionModel.count > 1)
    readonly property bool showPower: cfgBool("showPowerButtons", true)
    readonly property bool showHibernate: cfgBool("showHibernate", false)
    readonly property string userSelector: String(cfg("showUserSelector", "auto")).toLowerCase()

    // unidad de escala: todo se dimensiona respecto a 1080 px de alto
    readonly property real u: Math.max(0.6, root.height / 1080)

    property date now: new Date()
    property bool busy: false

    function cap(s) {
        return s.length > 0 ? s.charAt(0).toUpperCase() + s.slice(1) : s
    }

    function realName() {
        try {
            var v = userModel.data(userModel.index(userBox.currentIndex, 0), Qt.UserRole + 2)
            return v ? String(v) : ""
        } catch (e) {
            return ""
        }
    }

    function displayName() {
        var r = realName()
        return r.length > 0 ? r : userBox.currentText
    }

    function tryLogin() {
        if (busy || userBox.currentText.length === 0) return
        errorText.text = ""
        busy = true
        sddm.login(userBox.currentText, passwordField.text, sessionBox.currentIndex)
    }

    // ---- fondo ----
    Image {
        id: bg
        anchors.fill: parent
        source: root.cfg("background", "backgrounds/default.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: root.baseColor
        opacity: root.dim
    }

    // ---- reloj ----
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Column {
        visible: root.showClock
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 72 * root.u
        anchors.left: root.panelOnRight ? parent.left : undefined
        anchors.right: root.panelOnRight ? undefined : parent.right
        anchors.leftMargin: 72 * root.u
        anchors.rightMargin: 72 * root.u
        spacing: 4 * root.u

        Text {
            text: Qt.formatTime(root.now, root.clockFormat)
            color: root.textColor
            font.pixelSize: 120 * root.u
            font.weight: Font.Medium
        }
        Text {
            text: root.cap(Qt.locale().toString(root.now, root.dateFormat))
            color: root.mutedColor
            font.pixelSize: 28 * root.u
        }
    }

    // ---- panel ----
    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: root.panelOnRight ? parent.right : undefined
        anchors.left: root.panelOnRight ? undefined : parent.left
        width: Math.max(360 * root.u, root.width * root.panelPercent / 100)
        color: root.panelColor

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 80 * root.u
            spacing: 14 * root.u

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 96 * root.u
                Layout.preferredHeight: 96 * root.u
                radius: width / 2
                color: root.accentColor

                Text {
                    anchors.centerIn: parent
                    text: {
                        var n = root.displayName()
                        return n.length > 0 ? n.charAt(0).toUpperCase() : "?"
                    }
                    color: root.accentTextColor
                    font.pixelSize: 44 * root.u
                    font.weight: Font.Medium
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.displayName()
                color: root.textColor
                font.pixelSize: 20 * root.u
                elide: Text.ElideRight
            }

            ThemedCombo {
                id: userBox
                Layout.fillWidth: true
                scaleUnit: root.u
                fieldColor: root.fieldColor
                borderColor: root.borderColor
                accentColor: root.accentColor
                textColor: root.textColor
                mutedColor: root.mutedColor
                visible: root.userSelector === "true" || (root.userSelector !== "false" && userModel.count > 1)
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 44 * root.u
                enabled: !root.busy
                echoMode: TextInput.Password
                placeholderText: "Contraseña"
                placeholderTextColor: root.mutedColor
                color: root.textColor
                selectionColor: root.accentColor
                selectedTextColor: root.accentTextColor
                font.pixelSize: 16 * root.u
                leftPadding: 14 * root.u
                focus: true
                background: Rectangle {
                    radius: 8 * root.u
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
                font.pixelSize: 13 * root.u
            }

            Text {
                id: errorText
                Layout.fillWidth: true
                visible: text.length > 0
                color: root.dangerColor
                font.pixelSize: 14 * root.u
                wrapMode: Text.WordWrap
            }

            ThemedButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 44 * root.u
                scaleUnit: root.u
                primary: true
                accentColor: root.accentColor
                accentTextColor: root.accentTextColor
                fieldColor: root.fieldColor
                borderColor: root.borderColor
                textColor: root.textColor
                enabled: !root.busy
                text: root.busy ? "Entrando…" : "Iniciar sesión"
                onClicked: root.tryLogin()
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.showPower
                spacing: 8 * root.u

                ThemedButton {
                    Layout.fillWidth: true
                    scaleUnit: root.u
                    fieldColor: root.fieldColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    text: "Apagar"
                    visible: sddm.canPowerOff
                    onClicked: sddm.powerOff()
                }
                ThemedButton {
                    Layout.fillWidth: true
                    scaleUnit: root.u
                    fieldColor: root.fieldColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    text: "Reiniciar"
                    visible: sddm.canReboot
                    onClicked: sddm.reboot()
                }
                ThemedButton {
                    Layout.fillWidth: true
                    scaleUnit: root.u
                    fieldColor: root.fieldColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    text: "Suspender"
                    visible: sddm.canSuspend
                    onClicked: sddm.suspend()
                }
                ThemedButton {
                    Layout.fillWidth: true
                    scaleUnit: root.u
                    fieldColor: root.fieldColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    text: "Hibernar"
                    visible: root.showHibernate && sddm.canHibernate
                    onClicked: sddm.hibernate()
                }
            }

            // Selector de sesion: oculto si solo hay una; si hay varias, discreto al final del panel.
            // Siempre existe (aunque no se vea) porque sddm.login necesita su indice.
            ThemedCombo {
                id: sessionBox
                Layout.fillWidth: true
                Layout.topMargin: 10 * root.u
                Layout.preferredHeight: 30 * root.u
                font.pixelSize: 12 * root.u
                opacity: 0.75
                scaleUnit: root.u
                fieldColor: root.fieldColor
                borderColor: root.borderColor
                accentColor: root.accentColor
                textColor: root.textColor
                mutedColor: root.mutedColor
                visible: root.showSessionSelector
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
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
