import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../../core/connectivity_provider.dart';

class WeatherService {
  final String _apiKey = ApiConstants.openWeatherApiKey;
  late WeatherFactory _wf;

  WeatherService() {
    _wf = WeatherFactory(_apiKey);
  }

  Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality ?? place.subAdministrativeArea}, ${place.country}";
      }
      return "Unknown Location";
    } catch (e) {
      return "Unknown Location";
    }
  }

  Future<String> getCityNameFromCoords(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      String name = "";
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final city = data[0]['name'];
          final country = data[0]['country'];
          name = "$city, $country";
        }
      }
      if (name.isEmpty) {
        name = await getLocationName(lat, lon);
      }
      final box = await Hive.openBox('weather_cache');
      await box.put('location_name', name);
      return name;
    } catch (e) {
      final name = await getLocationName(lat, lon);
      final box = await Hive.openBox('weather_cache');
      await box.put('location_name', name);
      return name;
    }
  }

  Future<List<Weather>> getForecast(double lat, double lon) async {
    try {
      final forecast = await _wf.fiveDayForecastByLocation(lat, lon);
      if (forecast.isNotEmpty) {
        final box = await Hive.openBox('weather_cache');
        final forecastJson = forecast.map((w) => _weatherToJson(w)).toList();
        await box.put('forecast', forecastJson);
      }
      return forecast;
    } catch (e) {
      print('Error fetching forecast: $e');
      return [];
    }
  }

  Future<Weather?> getCurrentWeather() async {
    try {
      Position position = await _determinePosition();
      final weather = await _wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      if (weather != null) {
        final box = await Hive.openBox('weather_cache');
        await box.put('current_weather', _weatherToJson(weather));
      }
      return weather;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<Weather?> getCachedWeather() async {
    try {
      final box = await Hive.openBox('weather_cache');
      final data = box.get('current_weather');
      if (data != null) {
        return _weatherFromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Error loading cached weather: $e');
    }
    return null;
  }

  Future<List<Weather>> getCachedForecast() async {
    try {
      final box = await Hive.openBox('weather_cache');
      final List? data = box.get('forecast');
      if (data != null) {
        return data.map((jsonMap) => _weatherFromJson(Map<String, dynamic>.from(jsonMap))).toList();
      }
    } catch (e) {
      print('Error loading cached forecast: $e');
    }
    return [];
  }

  Future<String> getCachedLocationName() async {
    try {
      final box = await Hive.openBox('weather_cache');
      return box.get('location_name', defaultValue: 'Unknown Location');
    } catch (e) {
      return 'Unknown Location';
    }
  }

  Map<String, dynamic> _weatherToJson(Weather w) {
    return {
      'temp': w.temperature?.celsius,
      'temp_min': w.tempMin?.celsius,
      'temp_max': w.tempMax?.celsius,
      'humidity': w.humidity,
      'wind_speed': w.windSpeed,
      'condition_code': w.weatherConditionCode,
      'weather_main': w.weatherMain,
      'description': w.weatherDescription,
      'date': w.date?.toIso8601String(),
      'area_name': w.areaName,
    };
  }

  Weather _weatherFromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawJson = {
      'name': json['area_name'],
      'dt': json['date'] != null ? DateTime.parse(json['date']).millisecondsSinceEpoch ~/ 1000 : null,
      'main': {
        'temp': (json['temp'] as double?) != null ? (json['temp'] as double) + 273.15 : null,
        'temp_min': (json['temp_min'] as double?) != null ? (json['temp_min'] as double) + 273.15 : null,
        'temp_max': (json['temp_max'] as double?) != null ? (json['temp_max'] as double) + 273.15 : null,
        'humidity': json['humidity'],
      },
      'wind': {
        'speed': json['wind_speed'],
      },
      'weather': [
        {
          'id': json['condition_code'],
          'main': json['weather_main'],
          'description': json['description'],
        }
      ]
    };
    return Weather(rawJson);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  String getSprayingCondition(Weather? weather) {
    if (weather == null) return "Condition: Unknown";

    final double windSpeedKmh = (weather.windSpeed ?? 0) * 3.6; // converting m/s to km/h
    final description = weather.weatherDescription?.toLowerCase() ?? "";
    final bool isRaining = description.contains('rain') || 
                          description.contains('drizzle') || 
                          description.contains('storm');

    if (windSpeedKmh < 15 && !isRaining) {
      return "Condition: Excellent";
    } else if (isRaining || windSpeedKmh >= 15) {
      return "Condition: Do Not Spray";
    } else {
      return "Condition: Moderate";
    }
  }
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final currentWeatherProvider = FutureProvider<Weather?>((ref) async {
  final connectivity = ref.watch(connectivityProvider);
  final weatherService = ref.watch(weatherServiceProvider);
  if (connectivity == ConnectivityStatus.offline) {
    return weatherService.getCachedWeather();
  }
  return weatherService.getCurrentWeather();
});

