#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QVariantMap>
#include <QVariantList>

class WeatherBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit WeatherBackend(QObject *parent = nullptr);

    bool loading() const { return m_loading; }

    Q_INVOKABLE void fetchWeather(const QString &language = "ru",
                               const QString &cityOverride = "",
                               double latOverride = 0.0,
                               double lonOverride = 0.0);
    Q_INVOKABLE void resetAndFetch(const QString &language,
                                const QString &cityOverride = "",
                                double latOverride = 0.0,
                                double lonOverride = 0.0);

signals:
    void dataReady(QVariantMap data);
    void error(const QString &message);
    void loadingChanged();

private slots:
    void onGeoReply(QNetworkReply *reply);
    void onWeatherReply(QNetworkReply *reply, const QString &city);

private:
    QVariantMap buildData(const QByteArray &raw, const QString &city);
    QString symbolIcon(const QString &code);
    QString symbolDesc(const QString &code);
    QString directionArrow(double degrees);

    QNetworkAccessManager *m_nam;
    bool    m_loading  = false;
    double  m_lat      = 0.0;
    double  m_lon      = 0.0;
    QString m_city;
    QString m_language = "ru";
    bool    m_hasFix   = false;

    static constexpr const char *USER_AGENT =
        "weather-plasmoid/0.1 github.com/yourname/weather-plasmoid";
};