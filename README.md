# Weather Plasmoid

A lightweight, transparent hourly weather widget for **KDE Plasma 6**.

[Русская версия](README.ru.md)

![Plasma 6](https://img.shields.io/badge/Plasma-6.0%2B-1D99F3?logo=kde&logoColor=white)
![License](https://img.shields.io/badge/license-GPL--2.0--or--later-blue)

## Features

- Transparent, minimalist widget that blends into your desktop
- Automatic location detection via IP, or manual city/coordinates entry
- Hourly weather forecast
- Multi-language support (see `LanguageDialog.qml`)
- Native C++ backend plugin for fast, efficient data fetching
- Weather data provided by the [MET Norway Weather API](https://api.met.no/) — no API key required

## Screenshots

*(add a screenshot or GIF of the widget here)*

## Requirements

- KDE Plasma **6.0** or later
- Qt 6
- KDE Frameworks 6 (KF6)
- CMake ≥ 3.20
- A C++ compiler with C++17 support

## Installation

```bash
git clone https://github.com/zuzayka/weather-plasmoid.git
cd weather-plasmoid
./build.sh
./install.sh
```

`install.sh` copies the compiled backend plugin into the system QML path and requires `sudo` for that step.

After installation, right-click your desktop or panel → **Add Widgets** → search for **"Weather Plasmoid"**.

## Uninstallation

```bash
rm -rf ~/.local/share/plasma/plasmoids/org.kde.weather-plasmoid
sudo rm -f /usr/lib/qt6/qml/org/kde/weatherbackend/libweather-backend-plugin.so
kquitapp6 plasmashell && plasmashell &
```

## How it works

- On first run, the widget determines your location automatically via [ip-api.com](http://ip-api.com/).
- You can override this and set a fixed city or coordinates in the widget settings.
- Forecast data is fetched from the MET Norway `locationforecast/2.0/compact` endpoint, which requires no authentication but does require a descriptive `User-Agent` header (already set in the backend).

## Project structure

```
.
├── build.sh                 # Build script (CMake + compile)
├── install.sh                # Install script (copies files, restarts plasmashell)
├── CMakeLists.txt            # Root build config
├── package/                  # Plasmoid package (QML frontend)
│   ├── metadata.json
│   └── contents/
│       ├── config/
│       └── ui/                # QML UI, icons, dialogs
└── weather-backend/          # Native C++ backend plugin
    ├── CMakeLists.txt
    └── src/
```

## Contributing

Issues and pull requests are welcome. If you'd like to add a new language, translate `LanguageDialog.qml` and open a PR.

## License

This project is licensed under the **GPL-2.0-or-later** license — see [LICENSE](LICENSE) for details.

## Credits

- Weather data: [MET Norway](https://api.met.no/)
- Weather icons: [Yr.no Weather Symbols](https://github.com/nrkno/yr-weather-symbols)
- IP geolocation: [ip-api.com](http://ip-api.com/)
