#include "WeatherBackend.h"
#include <cmath>

#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QUrlQuery>
#include <QDateTime>

WeatherBackend::WeatherBackend(QObject *parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
{}

void WeatherBackend::fetchWeather(const QString &language,
                                   const QString &cityOverride,
                                   double latOverride,
                                   double lonOverride)
{
    if (m_loading) return;
    m_loading = true;
    m_language = language;
    emit loadingChanged();

    // Если заданы координаты вручную — используем их
    if (latOverride != 0.0 || lonOverride != 0.0) {
        m_lat    = latOverride;
        m_lon    = lonOverride;
        m_city   = cityOverride.isEmpty() ? QString("%1, %2")
                       .arg(latOverride).arg(lonOverride) : cityOverride;
        m_hasFix = true;
    }

    if (m_hasFix) {
        QUrl url("https://api.met.no/weatherapi/locationforecast/2.0/compact");
        QUrlQuery q;
        q.addQueryItem("lat", QString::number(m_lat, 'f', 4));
        q.addQueryItem("lon", QString::number(m_lon, 'f', 4));
        url.setQuery(q);

        QNetworkRequest req(url);
        req.setRawHeader("User-Agent", USER_AGENT);
        req.setRawHeader("Accept",     "application/json");

        auto *reply = m_nam->get(req);
        connect(reply, &QNetworkReply::finished, this, [this, reply]() {
            onWeatherReply(reply, m_city);
        });
    } else {
        QUrl geoUrl(QString("http://ip-api.com/json/?fields=lat,lon,city,timezone&lang=%1")
                    .arg(language));
        auto *reply = m_nam->get(QNetworkRequest(geoUrl));
        connect(reply, &QNetworkReply::finished, this, [this, reply]() {
            onGeoReply(reply);
        });
    }
}

void WeatherBackend::resetAndFetch(const QString &language,
                                    const QString &cityOverride,
                                    double latOverride,
                                    double lonOverride)
{
    // Сбрасываем фикс только если координаты не заданы вручную
    if (latOverride == 0.0 && lonOverride == 0.0)
        m_hasFix = false;
    fetchWeather(language, cityOverride, latOverride, lonOverride);
}

void WeatherBackend::onGeoReply(QNetworkReply *reply)
{
    reply->deleteLater();

    if (reply->error() == QNetworkReply::NoError) {
        const auto obj = QJsonDocument::fromJson(reply->readAll()).object();
        m_lat  = obj["lat"].toDouble(55.7558);
        m_lon  = obj["lon"].toDouble(37.6176);
        m_city = obj["city"].toString("Москва");
    } else {
        m_lat  = 55.7558;
        m_lon  = 37.6176;
        m_city = "Москва";
    }
    m_hasFix = true;

    QUrl url("https://api.met.no/weatherapi/locationforecast/2.0/compact");
    QUrlQuery q;
    q.addQueryItem("lat", QString::number(m_lat, 'f', 4));
    q.addQueryItem("lon", QString::number(m_lon, 'f', 4));
    url.setQuery(q);

    QNetworkRequest req(url);
    req.setRawHeader("User-Agent", USER_AGENT);
    req.setRawHeader("Accept",     "application/json");

    auto *wreply = m_nam->get(req);
    connect(wreply, &QNetworkReply::finished, this, [this, wreply]() {
        onWeatherReply(wreply, m_city);
    });
}

void WeatherBackend::onWeatherReply(QNetworkReply *reply, const QString &city)
{
    reply->deleteLater();
    m_loading = false;
    emit loadingChanged();

    if (reply->error() != QNetworkReply::NoError) {
        emit error(reply->errorString());
        return;
    }

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (status != 200 && status != 203) {
        emit error(QString("HTTP %1").arg(status));
        return;
    }

    const QByteArray raw = reply->readAll();
    if (raw.isEmpty()) {
        emit error("Пустой ответ");
        return;
    }

    emit dataReady(buildData(raw, city));
}

QVariantMap WeatherBackend::buildData(const QByteArray &raw, const QString &city)
{
    const QJsonObject root =
        QJsonDocument::fromJson(raw).object();

    const QJsonArray series =
        root["properties"].toObject()["timeseries"].toArray();

    const QDateTime now = QDateTime::currentDateTimeUtc();

    int startIdx = 0;
    for (int i = 0; i < series.size(); ++i) {
        const QString ts = series[i].toObject()["time"].toString();
        if (QDateTime::fromString(ts, Qt::ISODate) >= now) {
            startIdx = i;
            break;
        }
    }

    QVariantList hours;
    for (int i = startIdx, added = 0;
         i < series.size() && added < 10;
         ++i)
    {
        const QJsonObject entry   = series[i].toObject();
        const QString     tsStr   = entry["time"].toString();
        const QJsonObject data    = entry["data"].toObject();
        const QJsonObject instant = data["instant"].toObject()
                                        ["details"].toObject();
        const QJsonObject next1   = data["next_1_hours"].toObject();
        if (next1.isEmpty()) continue;

        const QString symbol = next1["summary"].toObject()
                                   ["symbol_code"].toString();

        const double tempC = instant["air_temperature"].toDouble();
        const double wind  = instant["wind_speed"].toDouble();

        QDateTime utc = QDateTime::fromString(tsStr, Qt::ISODate);
        utc.setTimeSpec(Qt::UTC);
        const QString hourLabel = utc.toLocalTime().toString("HH:mm");

        const double windDir = instant["wind_from_direction"].toDouble(-1);

        QVariantMap h;
        h["hour"] = hourLabel;
        h["temp"] = QString::number(qRound(tempC));
        h["wind"] = QString::number(qRound(wind));
        h["windDir"] = windDir >= 0 ? directionArrow(windDir) : "";
        h["icon"] = symbolIcon(symbol);
        h["desc"] = symbolDesc(symbol);
        hours.append(h);
        ++added;
    }

    const QVariantMap first = hours.isEmpty()
        ? QVariantMap()
        : hours.first().toMap();

    QVariantMap current;
    current["temp"] = first.value("temp", "–");
    current["desc"] = first.value("desc", "");
    current["icon"] = first.value("icon", "");

    QVariantMap result;
    result["city"]    = city;
    result["current"] = current;
    result["hours"]   = hours;
    return result;
}

QString WeatherBackend::symbolIcon(const QString &code)
{
    const QString c = code.section('_', 0, 0);
    if (c == "clearsky")                         return "clearsky.svg";
    if (c == "fair")                             return "fair.svg";
    if (c == "partlycloudy")                     return "partlycloudy.svg";
    if (c == "cloudy")                           return "cloudy.svg";
    if (c == "fog")                              return "fog.svg";
    if (c == "drizzle")                          return "lightrain.svg";
    if (c == "lightrain")                        return "lightrain.svg";
    if (c == "rain")                             return "rain.svg";
    if (c == "heavyrain")                        return "heavyrain.svg";
    if (c == "lightrainshowers")                 return "lightrainshowers.svg";
    if (c == "rainshowers")                      return "rainshowers.svg";
    if (c == "heavyrainshowers")                 return "heavyrainshowers.svg";
    if (c == "lightsleet")                       return "lightsleet.svg";
    if (c == "sleet")                            return "lightsleet.svg";
    if (c == "heavysleet")                       return "heavysleet.svg";
    if (c == "lightsnow")                        return "lightsnow.svg";
    if (c == "snow")                             return "lightsnow.svg";
    if (c == "heavysnow")                        return "heavysnow.svg";
    if (c == "lightsnowshowers")                 return "lightsnowshowers.svg";
    if (c == "snowshowers")                      return "snowshowers.svg";
    if (c.contains("thunder"))                   return "thunder.svg";
    return "question.svg";
}

QString WeatherBackend::symbolDesc(const QString &code)
{
    const QString c = code.section('_', 0, 0);

    if (m_language == "ru") {
        if (c == "clearsky")                     return "Ясно";
        if (c == "fair")                         return "Малооблачно";
        if (c == "partlycloudy")                 return "Переменная облачность";
        if (c == "cloudy")                       return "Пасмурно";
        if (c == "fog")                          return "Туман";
        if (c == "drizzle")                      return "Морось";
        if (c == "lightrain")                    return "Небольшой дождь";
        if (c == "rain")                         return "Дождь";
        if (c == "heavyrain")                    return "Сильный дождь";
        if (c.contains("shower"))                return "Ливень";
        if (c.contains("sleet"))                 return "Мокрый снег";
        if (c.contains("snow"))                  return "Снег";
        if (c.contains("thunder"))               return "Гроза";
        return "Переменная погода";
    } else {
        if (c == "clearsky")                     return "Clear sky";
        if (c == "fair")                         return "Fair";
        if (c == "partlycloudy")                 return "Partly cloudy";
        if (c == "cloudy")                       return "Cloudy";
        if (c == "fog")                          return "Fog";
        if (c == "drizzle")                      return "Drizzle";
        if (c == "lightrain")                    return "Light rain";
        if (c == "rain")                         return "Rain";
        if (c == "heavyrain")                    return "Heavy rain";
        if (c.contains("shower"))                return "Showers";
        if (c.contains("sleet"))                 return "Sleet";
        if (c.contains("snow"))                  return "Snow";
        if (c.contains("thunder"))               return "Thunderstorm";
        return "Variable";
    }
}

QString WeatherBackend::directionArrow(double deg)
{
    deg = std::fmod(deg + 180.0, 360.0);
    const int idx = int((deg + 22.5) / 45.0) % 8;
    const QString arrows[] = { "↑", "↗", "→", "↘", "↓", "↙", "←", "↖" };
    return arrows[idx];
}