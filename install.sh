#!/usr/bin/env bash
set -e
cmake --install build

# Копируем .so в системный путь QML
sudo cp "$HOME/.local/share/plasma/plasmoids/org.kde.weather-plasmoid/contents/lib/libweather-backend-plugin.so" \
        /usr/lib/qt6/qml/org/kde/weatherbackend/libweather-backend-plugin.so

cp "$HOME/weather-plasmoid/package/contents/config/main.xml" \
"$HOME/.local/share/plasma/plasmoids/org.kde.weather-plasmoid/contents/config/main.xml"

kquitapp6 plasmashell 2>/dev/null || true
sleep 1
plasmashell > /dev/null 2>&1 &
echo "✓ Установлено. Ищите виджет в «Добавить виджеты»."