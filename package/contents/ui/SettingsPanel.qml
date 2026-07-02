import QtQuick 2.15
import QtQuick.Layouts 1.15

Window {
    id: panel
    width: 280
    height: contentColumn.implicitHeight + 24
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    property var tr: ({})
    property string currentLang: "ru"
    property bool useFahrenheit: false
    property string windUnit: "м/с"

    signal refreshRequested()
    signal fontPlusRequested()
    signal fontMinusRequested()
    signal colorRequested(string color)
    signal tempUnitRequested(bool fahrenheit)
    signal windUnitRequested(string unit)
    signal locationRequested()
    signal moscowRequested()
    signal londonRequested()
    signal languageRequested()

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 10
        border.color: Qt.rgba(1,1,1,0.15)
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 4

            PanelButton {
                text: "🌐:"
                onClicked: panel.languageRequested()
            }
            PanelSeparator {}

            PanelButton {
                text: panel.tr.refresh || "Обновить"
                onClicked: panel.refreshRequested()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                PanelButton {
                    Layout.fillWidth: true
                    text: panel.tr.fontPlus || "Текст +"
                    onClicked: panel.fontPlusRequested()
                }
                PanelButton {
                    Layout.fillWidth: true
                    text: panel.tr.fontMinus || "Текст −"
                    onClicked: panel.fontMinusRequested()
                }
            }
            PanelSeparator {}

            PanelButton {
                text: panel.tr.colorWhite || "Белый"
                onClicked: panel.colorRequested("#ffffff")
            }
            PanelButton {
                text: panel.tr.colorGray || "Серый"
                onClicked: panel.colorRequested("#d9d9d9")
            }
            PanelButton {
                text: panel.tr.colorBlack || "Чёрный"
                onClicked: panel.colorRequested("#000000")
            }
            PanelButton {
                text: panel.tr.colorYellow || "Жёлтый"
                onClicked: panel.colorRequested("#ffe066")
            }
            PanelButton {
                text: panel.tr.colorBlue || "Голубой"
                onClicked: panel.colorRequested("#7ecfff")
            }
            PanelButton {
                text: panel.tr.colorGreen || "Зелёный"
                onClicked: panel.colorRequested("#7effa0")
            }
            PanelSeparator {}

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                PanelButton {
                    Layout.fillWidth: true
                    checked: !panel.useFahrenheit
                    text: panel.tr.tempC || "°C"
                    onClicked: panel.tempUnitRequested(false)
                }
                PanelButton {
                    Layout.fillWidth: true
                    checked: panel.useFahrenheit
                    text: panel.tr.tempF || "°F"
                    onClicked: panel.tempUnitRequested(true)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                PanelButton {
                    Layout.fillWidth: true
                    checked: panel.windUnit !== "mph"
                    text: panel.tr.windLocal || "м/с"
                    onClicked: panel.windUnitRequested(
                        panel.currentLang === "ru" ? "м/с" : "m/s")
                }
                PanelButton {
                    Layout.fillWidth: true
                    checked: panel.windUnit === "mph"
                    text: panel.tr.windMph || "mph"
                    onClicked: panel.windUnitRequested("mph")
                }
            }
            PanelSeparator {}

            PanelButton {
                text: panel.tr.location || "📍 Ввести местоположение"
                onClicked: panel.locationRequested()
            }
            PanelButton {
                text: panel.tr.moscow || "📍 Москва"
                onClicked: panel.moscowRequested()
            }
            PanelButton {
                text: panel.tr.london || "📍 Лондон"
                onClicked: panel.londonRequested()
            }
            PanelSeparator {}

            PanelButton {
                text: panel.currentLang === "ru" ? "✕ Выйти из меню" : "✕ Close menu"
                onClicked: panel.visible = false
            }

            Item { Layout.preferredHeight: 4 }
        }
    }

    component PanelButton: Rectangle {
        id: btnRoot
        property string text: ""
        property bool checked: false
        signal clicked()

        Layout.fillWidth: true
        height: 30
        radius: 6
        color: checked ? Qt.rgba(1,1,1,0.18)
               : (mouseArea.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent")

        Text {
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            text: btnRoot.text
            color: "#ffffff"
            font.pixelSize: 13
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btnRoot.clicked()
        }
    }

    component PanelSeparator: Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(1,1,1,0.1)
        Layout.topMargin: 4
        Layout.bottomMargin: 4
    }
}