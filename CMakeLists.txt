cmake_minimum_required(VERSION 3.20)
project(weather-plasmoid)

include(GNUInstallDirs)

set(PLASMOID_ID "org.kde.weather-plasmoid")
set(INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/share/plasma/plasmoids/${PLASMOID_ID}")

# Устанавливаем QML-пакет
install(DIRECTORY package/
    DESTINATION ${INSTALL_DIR}
    FILES_MATCHING
        PATTERN "*.qml"
        PATTERN "*.json"
        PATTERN "*.svg"
)

# Собираем C++ плагин
add_subdirectory(weather-backend)