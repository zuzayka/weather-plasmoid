cmake_minimum_required(VERSION 3.20)
project(weather-backend VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Network Qml Quick)

set(PLUGIN_URI "org.kde.weatherbackend")

# Классический способ — работает со всеми версиями Qt6
add_library(weather-backend-plugin SHARED
    src/plugin.cpp
    src/WeatherBackend.cpp
    src/WeatherBackend.h
)

target_link_libraries(weather-backend-plugin PRIVATE
    Qt6::Core
    Qt6::Network
    Qt6::Qml
    Qt6::Quick
)

target_compile_definitions(weather-backend-plugin PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_PLUGIN
)

# qmldir нужен чтобы QML-движок нашёл плагин
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/qmldir"
"module ${PLUGIN_URI}
plugin weather-backend-plugin
")

install(TARGETS weather-backend-plugin
    DESTINATION ${CMAKE_INSTALL_PREFIX}/share/plasma/plasmoids/org.kde.weather-plasmoid/contents/lib
)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/qmldir"
    DESTINATION ${CMAKE_INSTALL_PREFIX}/share/plasma/plasmoids/org.kde.weather-plasmoid/contents/lib
)
