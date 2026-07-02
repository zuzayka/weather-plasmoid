# Weather Plasmoid

Прозрачный почасовой виджет погоды для **KDE Plasma 6**.

🇬🇧 [Read in English](README.md)

![Plasma 6](https://img.shields.io/badge/Plasma-6-1D99F3?logo=kde&logoColor=white)
![License](https://img.shields.io/badge/license-GPL--2.0--or--later-blue)

## Возможности

- Аккуратная прозрачная карточка погоды, вписывающаяся в оформление рабочего стола
- Отображение почасового прогноза
- Автоматическое определение местоположения по IP (без настройки)
- Возможность вручную задать местоположение (координаты/город)
- Поддержка нескольких языков
- Данные о погоде от [MET Norway](https://api.met.no) — бесплатно, без API-ключа

## Скриншоты

![Виджет на рабочем столе](screenshots/widget-ru.png)
![Виджет на рабочем столе (en)](screenshots/widget-en.png)
![Настройки виджета](screenshots/widget-settings-ru.png)
![Настройки виджета (en)](screenshots/widget-settings-en.png)

## Требования

- KDE Plasma 6.0+
- Qt 6
- CMake 3.20+
- KDE Frameworks 6 (Plasma и стандартные QML-зависимости KF6)
- Компилятор C++ (GCC или Clang)

## Установка

Склонируй репозиторий и запусти скрипты сборки/установки:

```bash
git clone https://github.com/zuzayka/weather-plasmoid.git
cd weather-plasmoid
./build.sh
./install.sh
```

Скрипт установки:
1. Установит пакет плазмоида в `~/.local/share/plasma/plasmoids/`
2. Скопирует собранный backend-плагин в путь импорта Qt6 QML (потребуется `sudo`)
3. Перезапустит `plasmashell`

После установки: ПКМ по рабочему столу или панели → **Добавить виджеты** → найди **«Weather Plasmoid»**.

## Удаление

```bash
rm -rf ~/.local/share/plasma/plasmoids/org.kde.weather-plasmoid
sudo rm -f /usr/lib/qt6/qml/org/kde/weatherbackend/libweather-backend-plugin.so
kquitapp6 plasmashell && plasmashell &
```

## Как это работает

- При первом запуске (или если местоположение не задано вручную) виджет обращается к сервису [ip-api.com](http://ip-api.com), чтобы определить примерное местоположение по IP-адресу.
- Данные о погоде затем запрашиваются через [MET Norway Locationforecast API](https://api.met.no/weatherapi/locationforecast/2.0/documentation) — бесплатный сервис без регистрации, требующий лишь корректный заголовок `User-Agent`, который уже реализован в коде.
- Автоматическое местоположение можно переопределить фиксированным в настройках виджета.

## Настройка

Открой настройки виджета (ПКМ → **Настроить Weather Plasmoid...**), чтобы:
- Задать своё местоположение (город + координаты)
- Изменить язык отображения

## Структура проекта

```
weather-plasmoid/
├── .gitignore
├── build.sh                  # Скрипт сборки
├── install.sh                 # Скрипт установки
├── CMakeLists.txt              # Корневой конфиг CMake
├── LICENSE
├── README.md
├── README.ru.md
├── screenshots/                # Скриншоты для README
│   ├── widget-ru.png
│   ├── widget-en.png
│   ├── widget-settings-ru.png
│   └── widget-settings-en.png
├── package/                     # Пакет плазмоида
│   ├── metadata.json
│   └── contents/
│       ├── config/
│       │   └── main.xml
│       └── ui/                   # QML-интерфейс
│           ├── main.qml
│           ├── WeatherCard.qml
│           ├── WeatherModel.qml
│           ├── SettingsPanel.qml
│           ├── configGeneral.qml
│           ├── LanguageDialog.qml
│           ├── LocationDialog.qml
│           └── icons/              # Иконки погодных условий (SVG)
└── weather-backend/               # C++ backend-плагин (запросы к API)
    ├── CMakeLists.txt
    └── src/
        ├── plugin.cpp
        ├── plugin.json
        ├── WeatherBackend.cpp
        └── WeatherBackend.h
```

## Участие в разработке

Issues и pull request'ы приветствуются! Если хочешь добавить фичу или исправить баг — можно сначала открыть issue, чтобы обсудить изменение.

## Лицензия

Проект распространяется под лицензией **GPL-2.0-or-later** — подробности в файле [LICENSE](LICENSE).

## Благодарности

- Данные о погоде: [MET Norway](https://api.met.no)
- Иконки погоды: [Yr.no weather symbols](https://github.com/metno/weathericons)
- IP-геолокация: [ip-api.com](http://ip-api.com)
