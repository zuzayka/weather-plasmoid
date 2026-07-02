import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: locationDialog
    title: "Местоположение / Location"
    width: 320
    height: 280
    flags: Qt.Dialog
    modality: Qt.WindowModal

    signal locationAccepted(string city, real lat, real lon, string lang)

    property string initialCity: ""
    property real   initialLat:  0.0
    property real   initialLon:  0.0
    property string currentLang: "ru"

    property var labels: ({
        "ru": {
            "city":    "Город",
            "lat":     "Широта",
            "lon":     "Долгота",
            "cancel":  "Отмена",
            "city_ph": "Москва"
        },
        "en": {
            "city":    "City",
            "lat":     "Latitude",
            "lon":     "Longitude",
            "cancel":  "Cancel",
            "city_ph": "London"
        }
    })

    property var lbl: labels[currentLang] || labels["ru"]

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 10

            Text {
                text: locationDialog.lbl.city
                color: "#aaaaaa"
                font.pixelSize: 12
            }
            TextField {
                id: cityField
                Layout.fillWidth: true
                text: locationDialog.initialCity
                placeholderText: locationDialog.lbl.city_ph
                background: Rectangle {
                    color: Qt.rgba(1,1,1,0.08)
                    radius: 6
                    border.color: Qt.rgba(1,1,1,0.15)
                    border.width: 1
                }
                color: "#ffffff"
            }

            Text {
                text: locationDialog.lbl.lat
                color: "#aaaaaa"
                font.pixelSize: 12
            }
            TextField {
                id: latField
                Layout.fillWidth: true
                text: locationDialog.initialLat !== 0.0
                      ? locationDialog.initialLat.toString() : ""
                placeholderText: "55.7558"
                background: Rectangle {
                    color: Qt.rgba(1,1,1,0.08)
                    radius: 6
                    border.color: Qt.rgba(1,1,1,0.15)
                    border.width: 1
                }
                color: "#ffffff"
            }

            Text {
                text: locationDialog.lbl.lon
                color: "#aaaaaa"
                font.pixelSize: 12
            }
            TextField {
                id: lonField
                Layout.fillWidth: true
                text: locationDialog.initialLon !== 0.0
                      ? locationDialog.initialLon.toString() : ""
                placeholderText: "37.6176"
                background: Rectangle {
                    color: Qt.rgba(1,1,1,0.08)
                    radius: 6
                    border.color: Qt.rgba(1,1,1,0.15)
                    border.width: 1
                }
                color: "#ffffff"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    Layout.fillWidth: true
                    text: locationDialog.lbl.cancel
                    onClicked: locationDialog.close()
                }
                Button {
                    Layout.fillWidth: true
                    text: "OK"
                    onClicked: {
                        const lat  = parseFloat(latField.text)
                        const lon  = parseFloat(lonField.text)
                        const city = cityField.text.trim()
                        if (city !== "" && !isNaN(lat) && !isNaN(lon)) {
                            locationDialog.locationAccepted(city, lat, lon, locationDialog.currentLang)
                            locationDialog.close()
                        }
                    }
                }
            }
        }
    }
}