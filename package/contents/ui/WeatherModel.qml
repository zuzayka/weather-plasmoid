import QtQuick 2.15
import org.kde.weatherbackend 1.0

Item {
    id: model

    // Входные параметры из конфига
    property string cfgCityName: ""
    property real   latitude:    0.0
    property real   longitude:   0.0
    property string language:    "ru"

    // Состояние — данные от API
    property string cityName:    "Определение…"
    property string currentTemp: ""
    property string currentDesc: ""
    property string currentIcon: ""
    property string statusText:  ""
    property var    hours:       []

    function refresh() {
        statusText = "Обновление…"
        backend.fetchWeather(language, cfgCityName, latitude, longitude)
    }
    function setLanguage(lang) {
        language = lang
        statusText = "Обновление…"
        backend.resetAndFetch(lang, cfgCityName, latitude, longitude)
    }
    function setLocation(city, lat, lon) {
        cfgCityName = city
        latitude    = lat
        longitude   = lon
        statusText  = "Обновление…"
        backend.fetchWeather(language, city, lat, lon)
    }

    WeatherBackend {
        id: backend
        onDataReady: function(data) {
            model.cityName    = data.city
            model.currentTemp = data.current.temp
            model.currentDesc = data.current.desc
            model.currentIcon = data.current.icon
            model.hours       = data.hours
            model.statusText  = ""
        }
        onError: function(msg) {
            model.statusText = "⚠ " + msg
        }
    }

    Timer {
        interval:         30 * 60 * 1000
        running:          true
        repeat:           true
        triggeredOnStart: false
        onTriggered:      backend.fetchWeather(model.language, model.cfgCityName, model.latitude, model.longitude)
    }

    Component.onCompleted: backend.fetchWeather(language, cfgCityName, latitude, longitude)
}