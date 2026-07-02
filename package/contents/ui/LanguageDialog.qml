import QtQuick 2.15

Window {
    id: languageDialog
    title: ""
    width: 260
    height: 120
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.WindowModal

    signal languageSelected(string code)

    property var languages: [
        { "code": "ru", "flag": "🇷🇺" },
        { "code": "en", "flag": "🇬🇧" }
    ]

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 10
        border.color: Qt.rgba(1,1,1,0.15)
        border.width: 1

        Flow {
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 8

            Repeater {
                model: languageDialog.languages

                Text {
                    text: modelData.flag
                    font.pixelSize: 28
                    opacity: mouseArea.containsMouse ? 1.0 : 0.7

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            languageDialog.languageSelected(modelData.code)
                            languageDialog.close()
                        }
                    }
                }
            }
        }
    }
}