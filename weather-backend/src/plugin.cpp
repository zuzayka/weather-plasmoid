#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include "WeatherBackend.h"

class WeatherBackendPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid FILE "plugin.json")

public:
    void registerTypes(const char *uri) override
    {
        qmlRegisterType<WeatherBackend>(uri, 1, 0, "WeatherBackend");
    }
};

#include "plugin.moc"