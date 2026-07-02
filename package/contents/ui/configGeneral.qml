import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.0 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_fontSize:      fontSizeSlider.value
    property alias cfg_bgOpacity:     bgOpacitySlider.value
    property alias cfg_textColor:     textColorField.text
    property alias cfg_bgColor:       bgColorField.text
    property alias cfg_showWind:      showWindCheck.checked
    property alias cfg_cardStyle:     cardStyleCombo.currentValue
    property alias cfg_cityName:      cityNameField.text
    property alias cfg_latitude:      latField.text
    property alias cfg_longitude:     lonField.text
    property alias cfg_useFahrenheit: fahrenheitCheck.checked

    RowLayout {
        Kirigami.FormData.label: "Название города:"
        TextField {
            id: cityNameField
            placeholderText: "Москва"
            Layout.preferredWidth: 160
        }
    }
    RowLayout {
        Kirigami.FormData.label: "Широта (lat):"
        TextField {
            id: latField
            placeholderText: "55.7558"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            Layout.preferredWidth: 120
        }
    }
    RowLayout {
        Kirigami.FormData.label: "Долгота (lon):"
        TextField {
            id: lonField
            placeholderText: "37.6176"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            Layout.preferredWidth: 120
        }
    }
    Label {
        text: "Если координаты не заданы — определяется по IP"
        opacity: 0.6
        font.pixelSize: 11
    }

    RowLayout {
        Kirigami.FormData.label: "Размер текста:"
        Slider {
            id: fontSizeSlider
            from: 8; to: 22; stepSize: 1
            Layout.preferredWidth: 160
        }
        Label { text: fontSizeSlider.value + " px" }
    }

    RowLayout {
        Kirigami.FormData.label: "Прозрачность фона:"
        Slider {
            id: bgOpacitySlider
            from: 0.0; to: 1.0; stepSize: 0.05
            Layout.preferredWidth: 160
        }
        Label { text: Math.round(bgOpacitySlider.value * 100) + "%" }
    }

    RowLayout {
        Kirigami.FormData.label: "Цвет фона (hex):"
        TextField {
            id: bgColorField
            placeholderText: "#000000"
            Layout.preferredWidth: 100
        }
        Rectangle {
            width: 24; height: 24; radius: 4
            color: bgColorField.text
            border.color: "#888"; border.width: 1
        }
    }

    RowLayout {
        Kirigami.FormData.label: "Цвет текста (hex):"
        TextField {
            id: textColorField
            placeholderText: "#ffffff"
            Layout.preferredWidth: 100
        }
        Rectangle {
            width: 24; height: 24; radius: 4
            color: textColorField.text
            border.color: "#888"; border.width: 1
        }
    }

    RowLayout {
        Kirigami.FormData.label: "Стиль карточек:"
        ComboBox {
            id: cardStyleCombo
            model: [
                { text: "Скруглённые",  value: "rounded"    },
                { text: "Квадратные",   value: "square"     },
                { text: "Без рамки",    value: "borderless" }
            ]
            textRole:  "text"
            valueRole: "value"
        }
    }

    CheckBox {
        Kirigami.FormData.label: "Скорость ветра:"
        id: showWindCheck
        text: "Показывать"
    }

    CheckBox {
        Kirigami.FormData.label: "Единицы температуры:"
        id: fahrenheitCheck
        text: "Фаренгейт (°F)"
    }
}