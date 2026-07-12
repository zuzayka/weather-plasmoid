import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import Qt5Compat.GraphicalEffects

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property int    cfg_fontSize:      Plasmoid.configuration.fontSize
    property real   cfg_bgOpacity:     Plasmoid.configuration.bgOpacity
    property string cfg_textColor:     Plasmoid.configuration.textColor
    property string cfg_bgColor:       Plasmoid.configuration.bgColor
    property bool   cfg_showWind:      Plasmoid.configuration.showWind
    property string cfg_cardStyle:     Plasmoid.configuration.cardStyle
    property string cfg_language:      Plasmoid.configuration.language
    property string cfg_cityName:      Plasmoid.configuration.cityName
    property real   cfg_latitude:      Plasmoid.configuration.latitude
    property real   cfg_longitude:     Plasmoid.configuration.longitude
    property bool   cfg_useFahrenheit: Plasmoid.configuration.useFahrenheit
    property string cfg_windUnit:      Plasmoid.configuration.windUnit

    property int cardWidth:   cfg_fontSize * 5
    property int cardHeight:  cfg_fontSize * 8
    property int panelHeight: cardHeight + cfg_fontSize * 4

    property var menuTranslations: ({
        "ru": {
            "refresh":     "Обновить",
            "fontPlus":    "Размер текста: +",
            "fontMinus":   "Размер текста: −",
            "colorWhite":  "Цвет текста: Белый",
            "colorGray":   "Цвет текста: Серый",
            "colorBlack":  "Цвет текста: Чёрный",
            "colorYellow": "Цвет текста: Жёлтый",
            "colorBlue":   "Цвет текста: Голубой",
            "colorGreen":  "Цвет текста: Зелёный",
            "tempC":       "Температура: °C",
            "tempF":       "Температура: °F",
            "windLocal":   "Ветер: м/с",
            "windMph":     "Ветер: mph",
            "location":    "📍 Ввести местоположение",
            "moscow":      "📍 Москва",
            "london":      "📍 Лондон"
        },
        "en": {
            "refresh":     "Refresh",
            "fontPlus":    "Font size: +",
            "fontMinus":   "Font size: −",
            "colorWhite":  "Text color: White",
            "colorGray":   "Text color: Gray",
            "colorBlack":  "Text color: Black",
            "colorYellow": "Text color: Yellow",
            "colorBlue":   "Text color: Blue",
            "colorGreen":  "Text color: Green",
            "tempC":       "Temperature: °C",
            "tempF":       "Temperature: °F",
            "windLocal":   "Wind: m/s",
            "windMph":     "Wind: mph",
            "location":    "📍 Enter location",
            "moscow":      "📍 Moscow",
            "london":      "📍 London"
        }
    })

    property var tr: menuTranslations[cfg_language] || menuTranslations["ru"]

    function formatTemp(celsius) {
        if (cfg_useFahrenheit)
            return Math.round(celsius * 9 / 5 + 32) + "°F"
        return celsius + "°C"
    }

    function formatWind(ms) {
        if (cfg_windUnit === "mph")
            return String(Math.round(parseFloat(ms) * 2.237))
        return ms
    }

    readonly property string defaultBgColor: "#000000"
    function isValidHexColor(hex) {
        return /^#[0-9a-fA-F]{6}$/.test(hex)
    }
    property string cfg_bgColorSafe: isValidHexColor(cfg_bgColor) ? cfg_bgColor : defaultBgColor

    WeatherModel {
        id: weatherModel
        language:    root.cfg_language
        cfgCityName: root.cfg_cityName
        latitude:    root.cfg_latitude
        longitude:   root.cfg_longitude
    }

    Connections {
        target: Plasmoid.configuration
        function onLatitudeChanged() {
            weatherModel.latitude = Plasmoid.configuration.latitude
        }
        function onLongitudeChanged() {
            weatherModel.longitude = Plasmoid.configuration.longitude
        }
        function onCityNameChanged() {
            weatherModel.cfgCityName = Plasmoid.configuration.cityName
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.cfg_language === "ru" ? "⚙ Настройки" : "⚙ Settings"
            icon.name: "configure"
            onTriggered: root.openSettingsPanel()
        }
    ]

    function openSettingsPanel() {
        settingsPanel.tr            = root.tr
        settingsPanel.currentLang   = root.cfg_language
        settingsPanel.useFahrenheit = root.cfg_useFahrenheit
        settingsPanel.windUnit      = root.cfg_windUnit
        settingsPanel.visible = true
    }

    SettingsPanel {
        id: settingsPanel

        onRefreshRequested: {
            weatherModel.refresh()
        }
        onFontPlusRequested: {
            if (Plasmoid.configuration.fontSize < 22)
                Plasmoid.configuration.fontSize += 1
        }
        onFontMinusRequested: {
            if (Plasmoid.configuration.fontSize > 8)
                Plasmoid.configuration.fontSize -= 1
        }
        onColorRequested: function(color) {
            Plasmoid.configuration.textColor = color
        }
        onTempUnitRequested: function(fahrenheit) {
            Plasmoid.configuration.useFahrenheit = fahrenheit
            settingsPanel.useFahrenheit = fahrenheit
        }
        onWindUnitRequested: function(unit) {
            Plasmoid.configuration.windUnit = unit
            settingsPanel.windUnit = unit
        }
        onLocationRequested: {
            locationDialog.initialCity = root.cfg_cityName
            locationDialog.initialLat  = root.cfg_latitude
            locationDialog.initialLon  = root.cfg_longitude
            locationDialog.currentLang = root.cfg_language
            locationDialog.show()
            settingsPanel.visible = false
        }
        onMoscowRequested: {
            Plasmoid.configuration.cityName  = "Москва"
            Plasmoid.configuration.latitude  = 55.7558
            Plasmoid.configuration.longitude = 37.6176
            weatherModel.setLocation("Москва", 55.7558, 37.6176)
        }
        onLondonRequested: {
            Plasmoid.configuration.cityName  = "London"
            Plasmoid.configuration.latitude  = 51.5074
            Plasmoid.configuration.longitude = -0.1278
            weatherModel.setLocation("London", 51.5074, -0.1278)
        }
        onLanguageRequested: {
            settingsPanel.visible = false
            languageDialog.show()
        }
    }

    LocationDialog {
        id: locationDialog
        initialCity: root.cfg_cityName
        initialLat:  root.cfg_latitude
        initialLon:  root.cfg_longitude

        onLocationAccepted: function(city, lat, lon, lang) {
            Plasmoid.configuration.cityName  = city
            Plasmoid.configuration.latitude  = lat
            Plasmoid.configuration.longitude = lon
            Plasmoid.configuration.language  = lang
            weatherModel.setLanguage(lang)
            weatherModel.setLocation(city, lat, lon)
        }
    }

    LanguageDialog {
        id: languageDialog
        onLanguageSelected: function(code) {
            Plasmoid.configuration.language = code
            if (Plasmoid.configuration.windUnit !== "mph")
                Plasmoid.configuration.windUnit = code === "ru" ? "м/с" : "m/s"
            weatherModel.setLanguage(code)
            Plasmoid.destroy()
        }
    }

    fullRepresentation: Item {
        id: container
        width:  root.cardWidth * 10 + 80
        height: root.panelHeight

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Qt.rgba(
                parseInt(root.cfg_bgColorSafe.slice(1,3), 16) / 255,
                parseInt(root.cfg_bgColorSafe.slice(3,5), 16) / 255,
                parseInt(root.cfg_bgColorSafe.slice(5,7), 16) / 255,
                root.cfg_bgOpacity
            )
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1
        }

        ColumnLayout {
            anchors { fill: parent; margins: root.cfg_fontSize }
            spacing: root.cfg_fontSize / 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: weatherModel.cityName
                    color: root.cfg_textColor
                    font.pixelSize: root.cfg_fontSize + 2
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 6
                    visible: weatherModel.currentTemp !== ""

                    Image {
                        id: currentIcon
                        width:  root.cfg_fontSize + 4
                        height: root.cfg_fontSize + 4
                        anchors.verticalCenter: parent.verticalCenter
                        source: Qt.resolvedUrl("icons/" + weatherModel.currentIcon)
                        sourceSize.width:  width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: root.cfg_textColor
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: weatherModel.currentTemp !== ""
                              ? root.formatTemp(parseInt(weatherModel.currentTemp))
                                + (weatherModel.currentDesc !== "" ? "  " + weatherModel.currentDesc : "")
                              : ""
                        color: root.cfg_textColor
                        opacity: 0.8
                        font.pixelSize: root.cfg_fontSize
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: 6
                clip: true
                model: weatherModel.hours

                delegate: WeatherCard {
                    hour:        modelData.hour
                    temperature: root.cfg_useFahrenheit
                                 ? String(Math.round(parseInt(modelData.temp) * 9 / 5 + 32))
                                 : modelData.temp
                    tempUnit:    root.cfg_useFahrenheit ? "°F" : "°C"
                    windSpeed:   root.formatWind(modelData.wind)
                    windDir:     modelData.windDir
                    windUnit:    root.cfg_windUnit
                    icon:        modelData.icon
                    showWind:    root.cfg_showWind
                    cardStyle:   root.cfg_cardStyle
                    textColor:   root.cfg_textColor
                    fontSize:    root.cfg_fontSize
                    cardHeight:  root.cardHeight
                    cardWidth:   root.cardWidth
                }
            }

            Text {
                visible: weatherModel.statusText !== ""
                text: weatherModel.statusText
                color: root.cfg_textColor
                opacity: 0.5
                font.pixelSize: root.cfg_fontSize - 3
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}