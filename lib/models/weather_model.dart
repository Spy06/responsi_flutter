class CurrentWeather {
  final DateTime time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;

  const CurrentWeather({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final rawTime = json['time'] as String?;
    return CurrentWeather(
      time: rawTime != null ? (DateTime.tryParse(rawTime) ?? DateTime.now()) : DateTime.now(),
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperature2mMax;
  final double temperature2mMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final String timezoneAbbreviation;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentMap = (json['current'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final dailyMap = (json['daily'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final times = (dailyMap['time'] as List<dynamic>?) ?? const [];
    final codes = (dailyMap['weather_code'] as List<dynamic>?) ?? const [];
    final maxTemps = (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps = (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final precipProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>?) ?? const [];

    final dailyList = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      final rawDate = times[i]?.toString() ?? '';
      dailyList.add(
        DailyForecast(
          date: DateTime.tryParse(rawDate) ?? DateTime.now().add(Duration(days: i)),
          weatherCode: i < codes.length ? ((codes[i] as num?)?.toInt() ?? 0) : 0,
          temperature2mMax:
              i < maxTemps.length ? ((maxTemps[i] as num?)?.toDouble() ?? 0.0) : 0.0,
          temperature2mMin:
              i < minTemps.length ? ((minTemps[i] as num?)?.toDouble() ?? 0.0) : 0.0,
          precipitationProbabilityMax:
              i < precipProbs.length ? ((precipProbs[i] as num?)?.toInt() ?? 0) : 0,
        ),
      );
    }

    return WeatherModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      timezoneAbbreviation: (json['timezone_abbreviation'] as String?) ?? '',
      current: CurrentWeather.fromJson(currentMap),
      daily: dailyList,
    );
  }

  int get todayRainProbability =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;

  double? get todayMaxTemp => daily.isNotEmpty ? daily.first.temperature2mMax : null;

  double? get todayMinTemp => daily.isNotEmpty ? daily.first.temperature2mMin : null;
}
