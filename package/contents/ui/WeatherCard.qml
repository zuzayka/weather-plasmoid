import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: card
    property string hour:        "--:--"
    property string temperature: "--"
    property string windSpeed:   "--"
    property string windDir:     ""
    property string windUnit:    "м/с"
    property string tempUnit:    "°C"
    property string icon:        "question.svg"
    property bool   showWind:    true
    property string cardStyle:   "rounded"
    property string textColor:   "#ffffff"
    property int    fontSize:    16
    property real   cardHeight:  100
    property real   cardWidth:   80

    width:  cardWidth
    height: cardHeight
    radius: cardStyle === "rounded" ? fontSize * 0.7 : 0
    color: cardStyle === "borderless"
           ? "transparent"
           : Qt.rgba(1, 1, 1, 0.08)
    border.color: cardStyle === "borderless"
                  ? "transparent"
                  : Qt.rgba(1, 1, 1, 0.15)
    border.width: 1

    Text {
        anchors.top: parent.top
        anchors.topMargin: cardHeight * 0.05
        anchors.horizontalCenter: parent.horizontalCenter
        text: card.hour
        color: card.textColor
        opacity: 0.6
        font.pixelSize: Math.round((card.fontSize - 3) * 1.2)
    }

    Image {
        id: weatherIcon
        anchors.top: parent.top
        anchors.topMargin: cardHeight * 0.22
        anchors.horizontalCenter: parent.horizontalCenter
        width:  card.fontSize + 12
        height: card.fontSize + 12
        source: Qt.resolvedUrl("icons/" + card.icon)
        sourceSize.width:  width
        sourceSize.height: height
        smooth: true
        antialiasing: true

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: card.textColor
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: cardHeight * 0.55
        anchors.horizontalCenter: parent.horizontalCenter
        text: card.temperature + card.tempUnit
        color: card.textColor
        font.pixelSize: card.fontSize
        font.bold: true
    }

    Row {
        visible: card.showWind
        anchors.bottom: parent.bottom
        anchors.bottomMargin: cardHeight * 0.05
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            text: card.windDir
            color: card.textColor
            opacity: 0.75
            font.pixelSize: Math.round((card.fontSize - 3) * 1.2)
            font.bold: true
        }
        Text {
            text: card.windSpeed + " " + card.windUnit
            color: card.textColor
            opacity: 0.6
            font.pixelSize: Math.round((card.fontSize - 4) * 1.2)
        }
    }
}