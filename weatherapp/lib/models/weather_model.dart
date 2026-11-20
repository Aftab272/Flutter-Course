class WeatherData {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double precipitation;
  final double uvIndex;
  final int weatherCode;
  final String conditionText;
  final String conditionIcon;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime lastUpdated;
  final String cityName;
  final String country;

  WeatherData({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitation,
    required this.uvIndex,
    required this.weatherCode,
    required this.conditionText,
    required this.conditionIcon,
    required this.hourly,
    required this.daily,
    required this.lastUpdated,
    required this.cityName,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'precipitation': precipitation,
      'uvIndex': uvIndex,
      'weatherCode': weatherCode,
      'conditionText': conditionText,
      'conditionIcon': conditionIcon,
      'hourly': hourly.map((h) => h.toJson()).toList(),
      'daily': daily.map((d) => d.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'cityName': cityName,
      'country': country,
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (json['apparentTemperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['windDirection'] as num?)?.toInt() ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
      conditionText: json['conditionText'] ?? 'Clear',
      conditionIcon: json['conditionIcon'] ?? 'wb_sunny',
      hourly: (json['hourly'] as List<dynamic>?)
              ?.map((h) => HourlyForecast.fromJson(h))
              .toList() ??
          [],
      daily: (json['daily'] as List<dynamic>?)
              ?.map((d) => DailyForecast.fromJson(d))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      cityName: json['cityName'] ?? 'Unknown',
      country: json['country'] ?? '',
    );
  }

  static WeatherData fromOpenMeteo(Map<String, dynamic> json, String cityName, String country) {
    final current = json['current'] ?? {};
    final hourlyData = json['hourly'] ?? {};
    final dailyData = json['daily'] ?? {};

    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    final apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
    final hum = (current['relative_humidity_2m'] as num?)?.toInt() ?? 50;
    final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
    final windDir = (current['wind_direction_10m'] as num?)?.toInt() ?? 0;
    final precip = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
    final code = (current['weather_code'] as num?)?.toInt() ?? 0;
    
    // UV Index from daily or hourly if available, else estimated
    double uv = 4.5;
    if (dailyData['uv_index_max'] != null && (dailyData['uv_index_max'] as List).isNotEmpty) {
      uv = (dailyData['uv_index_max'][0] as num?)?.toDouble() ?? 4.5;
    }

    final conditionInfo = _getWeatherCondition(code);

    // Parse hourly forecast (next 24 hours)
    List<HourlyForecast> hourlyList = [];
    if (hourlyData['time'] != null && hourlyData['temperature_2m'] != null) {
      final times = hourlyData['time'] as List;
      final temps = hourlyData['temperature_2m'] as List;
      final codes = hourlyData['weather_code'] as List?;
      
      final nowIndex = times.indexWhere((t) => DateTime.parse(t).isAfter(DateTime.now().subtract(const Duration(hours: 1))));
      final startIndex = nowIndex != -1 ? nowIndex : 0;
      final endIndex = (startIndex + 24).clamp(0, times.length);

      for (int i = startIndex; i < endIndex; i++) {
        final timeStr = times[i];
        final t = (temps[i] as num?)?.toDouble() ?? 0.0;
        final cCode = codes != null && i < codes.length ? (codes[i] as num?)?.toInt() ?? 0 : 0;
        final cond = _getWeatherCondition(cCode);
        hourlyList.add(HourlyForecast(
          time: DateTime.parse(timeStr),
          temperature: t,
          conditionIcon: cond['icon']!,
          conditionText: cond['text']!,
        ));
      }
    }

    // Parse daily forecast (next 7-10 days)
    List<DailyForecast> dailyList = [];
    if (dailyData['time'] != null && dailyData['temperature_2m_max'] != null) {
      final days = dailyData['time'] as List;
      final maxTemps = dailyData['temperature_2m_max'] as List;
      final minTemps = dailyData['temperature_2m_min'] as List;
      final codes = dailyData['weather_code'] as List?;

      for (int i = 0; i < days.length; i++) {
        final dayStr = days[i];
        final maxT = (maxTemps[i] as num?)?.toDouble() ?? 0.0;
        final minT = (minTemps[i] as num?)?.toDouble() ?? 0.0;
        final dCode = codes != null && i < codes.length ? (codes[i] as num?)?.toInt() ?? 0 : 0;
        final cond = _getWeatherCondition(dCode);
        dailyList.add(DailyForecast(
          date: DateTime.parse(dayStr),
          maxTemperature: maxT,
          minTemperature: minT,
          conditionIcon: cond['icon']!,
          conditionText: cond['text']!,
        ));
      }
    }

    return WeatherData(
      temperature: temp,
      apparentTemperature: apparentTemp,
      humidity: hum,
      windSpeed: wind,
      windDirection: windDir,
      precipitation: precip,
      uvIndex: uv,
      weatherCode: code,
      conditionText: conditionInfo['text']!,
      conditionIcon: conditionInfo['icon']!,
      hourly: hourlyList,
      daily: dailyList,
      lastUpdated: DateTime.now(),
      cityName: cityName,
      country: country,
    );
  }

  static Map<String, String> _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return {'text': 'Clear skies', 'icon': 'wb_sunny'};
      case 1:
      case 2:
      case 3:
        return {'text': 'Partly cloudy', 'icon': 'partly_cloudy_day'};
      case 45:
      case 48:
        return {'text': 'Foggy & misty', 'icon': 'foggy'};
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return {'text': 'Light drizzle', 'icon': 'grain'};
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return {'text': 'Moderate rain', 'icon': 'rainy'};
      case 71:
      case 73:
      case 75:
      case 77:
        return {'text': 'Snow showers', 'icon': 'ac_unit'};
      case 80:
      case 81:
      case 82:
        return {'text': 'Rain showers', 'icon': 'rainy'};
      case 85:
      case 86:
        return {'text': 'Snow flurries', 'icon': 'ac_unit'};
      case 95:
      case 96:
      case 99:
        return {'text': 'Thunderstorm', 'icon': 'thunderstorm'};
      default:
        return {'text': 'Fair weather', 'icon': 'wb_sunny'};
    }
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String conditionIcon;
  final String conditionText;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.conditionIcon,
    required this.conditionText,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temperature': temperature,
        'conditionIcon': conditionIcon,
        'conditionText': conditionText,
      };

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => HourlyForecast(
        time: DateTime.parse(json['time']),
        temperature: (json['temperature'] as num).toDouble(),
        conditionIcon: json['conditionIcon'] ?? 'wb_sunny',
        conditionText: json['conditionText'] ?? '',
      );
}

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String conditionIcon;
  final String conditionText;

  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.conditionIcon,
    required this.conditionText,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'maxTemperature': maxTemperature,
        'minTemperature': minTemperature,
        'conditionIcon': conditionIcon,
        'conditionText': conditionText,
      };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date']),
        maxTemperature: (json['maxTemperature'] as num).toDouble(),
        minTemperature: (json['minTemperature'] as num).toDouble(),
        conditionIcon: json['conditionIcon'] ?? 'wb_sunny',
        conditionText: json['conditionText'] ?? '',
      );
}
