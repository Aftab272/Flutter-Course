import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../data/database_helper.dart';
import '../models/weather_model.dart';
import '../models/city_model.dart';
import '../constants/api_keys.dart';

class WeatherService {
  static final WeatherService instance = WeatherService._init();
  WeatherService._init();

  // Fetch current GPS device location
  Future<CityLocation?> getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return CityLocation(
        cityName: 'My Location',
        country: 'GPS',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  // Fetch weather for coordinates, supporting Open-Meteo and OpenWeatherMap keys with SQLite cache fallback
  Future<WeatherData> getWeather({
    required double latitude,
    required double longitude,
    required String cityName,
    required String country,
  }) async {
    final locationKey = '${cityName}_$country';
    try {
      // Primary: Open-Meteo API
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = WeatherData.fromOpenMeteo(data, cityName, country);
        
        // Cache successfully fetched weather in SQLite
        await DatabaseHelper.instance.cacheWeather(locationKey, latitude, longitude, weather);
        return weather;
      } else {
        throw Exception('Open-Meteo HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Secondary / Fallback: OpenWeatherMap API using provided API keys
      try {
        final owmUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=${ApiKeys.openWeatherApiKey1}',
        );
        final owmResponse = await http.get(owmUrl).timeout(const Duration(seconds: 8));
        if (owmResponse.statusCode == 200) {
          final owmData = jsonDecode(owmResponse.body);
          final temp = (owmData['main']['temp'] as num).toDouble();
          final feelsLike = (owmData['main']['feels_like'] as num).toDouble();
          final humidity = (owmData['main']['humidity'] as num).toInt();
          final windSpeed = (owmData['wind']['speed'] as num).toDouble() * 3.6; // m/s to km/h
          final windDir = (owmData['wind']['deg'] as num?)?.toInt() ?? 0;
          final weatherList = owmData['weather'] as List? ?? [];
          final conditionText = weatherList.isNotEmpty ? weatherList[0]['description'] : 'Clear';
          final iconName = weatherList.isNotEmpty ? _mapOwmIcon(weatherList[0]['icon']) : 'wb_sunny';

          final weather = WeatherData(
            temperature: temp,
            apparentTemperature: feelsLike,
            humidity: humidity,
            windSpeed: windSpeed,
            windDirection: windDir,
            precipitation: 0.0,
            uvIndex: 4.5,
            weatherCode: 0,
            conditionText: conditionText,
            conditionIcon: iconName,
            hourly: [],
            daily: [],
            lastUpdated: DateTime.now(),
            cityName: cityName,
            country: country,
          );

          await DatabaseHelper.instance.cacheWeather(locationKey, latitude, longitude, weather);
          return weather;
        }
      } catch (owmError) {
        // Fall through to SQLite cache
      }

      // Final fallback: SQLite cache
      final cached = await DatabaseHelper.instance.getCachedWeather(locationKey);
      if (cached != null) {
        return cached;
      }
      throw Exception('No internet connection and no cached weather available for $cityName.');
    }
  }

  String _mapOwmIcon(String iconCode) {
    if (iconCode.contains('01')) return 'wb_sunny';
    if (iconCode.contains('02') || iconCode.contains('03') || iconCode.contains('04')) return 'partly_cloudy_day';
    if (iconCode.contains('09') || iconCode.contains('10')) return 'rainy';
    if (iconCode.contains('11')) return 'thunderstorm';
    if (iconCode.contains('13')) return 'ac_unit';
    if (iconCode.contains('50')) return 'foggy';
    return 'wb_sunny';
  }

  // Geocoding search for cities using Open-Meteo geocoding API
  Future<List<CityLocation>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) {
          return CityLocation(
            cityName: item['name'] ?? '',
            country: item['country'] ?? item['admin1'] ?? '',
            latitude: (item['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (item['longitude'] as num?)?.toDouble() ?? 0.0,
            isFavourite: false,
          );
        }).toList();
      }
    } catch (e) {
      // If geocoding fails, return empty list
    }
    return [];
  }
}
