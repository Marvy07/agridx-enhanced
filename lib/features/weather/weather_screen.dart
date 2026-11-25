import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import '../../shared/services/weather_service.dart';
import '../../shared/services/groq_service.dart';
import '../../core/connectivity_provider.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  bool _dailyNotification = false;
  late FlutterTts _flutterTts;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  
  Weather? _currentWeather;
  List<Weather> _forecast = [];
  String _locationName = "Loading...";
  String _aiSummary = "";
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _initTts();
    _initNotifications();
    _loadWeatherData();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
  }

  void _initNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      final weatherService = ref.read(weatherServiceProvider);
      final groqService = ref.read(groqServiceProvider);
      final connectivity = ref.read(connectivityProvider);
      final isOffline = connectivity == ConnectivityStatus.offline;

      if (isOffline) {
        final cachedWeather = await weatherService.getCachedWeather();
        final cachedForecast = await weatherService.getCachedForecast();
        final cachedLocName = await weatherService.getCachedLocationName();

        if (cachedWeather != null) {
          String locSummary = _generateLocalAdvisory(
            cachedWeather.temperature?.celsius ?? 25,
            cachedWeather.humidity ?? 50,
            cachedWeather.windSpeed ?? 0,
            cachedWeather.weatherDescription ?? 'clear',
            cachedLocName,
            cachedForecast,
          );

          if (mounted) {
            setState(() {
              _currentWeather = cachedWeather;
              _forecast = cachedForecast;
              _locationName = "$cachedLocName (Cached)";
              _aiSummary = "$locSummary\n\n[Offline Mode: Displaying Cached Weather Data]";
              _isLoading = false;
            });
          }
          return;
        } else {
          throw Exception('No internet connection and no cached weather data available.');
        }
      }

      // 1. Get Location with permission handling and fallback
      Position position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 10),
          );
        } else {
          // Fallback to Accra, Ghana
          position = _fallbackPosition();
        }
      } catch (e) {
        position = _fallbackPosition();
      }
      
      // 2. Get Real Location Name (Reverse Geocoding)
      String locName = await weatherService.getCityNameFromCoords(position.latitude, position.longitude);
      
      // 3. Get Current Weather
      Weather? weather = await weatherService.getCurrentWeather();
      
      // 4. Get Forecast
      List<Weather> forecast = await weatherService.getForecast(position.latitude, position.longitude);

      // Fallback to cache if the live API call returned null
      if (weather == null) {
        final cachedWeather = await weatherService.getCachedWeather();
        if (cachedWeather != null) {
          weather = cachedWeather;
          final cachedForecast = await weatherService.getCachedForecast();
          if (cachedForecast.isNotEmpty) {
            forecast = cachedForecast;
          }
          final cachedLoc = await weatherService.getCachedLocationName();
          locName = "$cachedLoc (Cached)";
        } else {
          throw Exception("Unable to fetch live weather and no cached data available. Check your internet connection.");
        }
      }

      if (mounted) {
        String locSummary = _generateLocalAdvisory(
          weather.temperature?.celsius ?? 25,
          weather.humidity ?? 50,
          weather.windSpeed ?? 0,
          weather.weatherDescription ?? 'clear',
          locName,
          forecast,
        );

        // Try getting AI summary if online
        final connState = ref.read(connectivityProvider);
        if (connState == ConnectivityStatus.online) {
          try {
            final forecastStrings = forecast.take(3).map((w) => '${w.weatherDescription}').toList();
            final aiSummary = await ref.read(groqServiceProvider).getWeatherSummary(
              locName,
              weather.temperature?.celsius ?? 25,
              weather.humidity ?? 50,
              weather.weatherDescription ?? 'clear',
              forecastStrings,
            );
            if (aiSummary.isNotEmpty && !aiSummary.contains('No advisory available')) {
              locSummary = aiSummary;
            }
          } catch (e) {
            print('Failed to get AI weather summary, falling back to local advisory: $e');
          }
        }

        if (mounted) {
          setState(() {
            _currentWeather = weather;
            _forecast = forecast;
            _locationName = locName;
            _aiSummary = locSummary;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Position _fallbackPosition() {
    return Position(
      latitude: 5.6037,
      longitude: -0.1870,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  String _getFallbackAdvisory(Weather w) {
    final temp = w.temperature?.celsius ?? 25;
    final humidity = w.humidity ?? 50;
    
    String advisory = "Current conditions show a temperature of ${temp.toStringAsFixed(0)}°C and ${humidity.toStringAsFixed(0)}% humidity. ";
    
    if (humidity > 80) {
      advisory += "High humidity might increase fungal risks. Monitor your crops closely. ";
    } else if (temp > 30) {
      advisory += "High temperatures observed. Ensure adequate irrigation to prevent heat stress. ";
    } else {
      advisory += "Conditions are relatively stable. Good time for routine maintenance. ";
    }
    
    advisory += "\n\nOutlook: Keep an eye on local forecasts for any sudden weather changes.";
    return advisory;
  }

  String _generateLocalAdvisory(double temp, double humidity, double wind, String conditions, String loc, List<Weather> forecast) {
    String today = "";
    final cond = conditions.toLowerCase();
    // Today Advisory Rules
    if (temp > 35) {
      today = "⚠️ Extreme Heat Alert: Temperatures are dangerously high today in $loc. Pause all pesticide spraying to prevent chemical burn. Focus heavily on deep irrigation during the cool evening or early morning hours to protect crops from severe heat stress.";
    } else if (temp >= 25 && temp <= 35 && humidity < 60) {
      today = "✅ Ideal Farming Conditions: The weather in $loc is currently optimal. Take advantage of the low humidity to safely apply fertilizers and spray necessary pesticides. Fungal disease risk remains low today.";
    } else if (temp >= 25 && temp <= 35 && humidity >= 60) {
      today = "⚠️ High Humidity Warning: The humid conditions in $loc are creating a breeding ground for fungal diseases. Closely inspect vulnerable crops like tomatoes for blight, and prepare preventive fungicide treatments if necessary.";
    } else if (cond.contains('rain') || cond.contains('drizzle') || cond.contains('storm')) {
      today = "🌧️ Rainfall Expected: Hold off on any chemical spraying today in $loc as rain will wash it away. Instead, use this natural watering to transplant new seedlings or focus on indoor equipment maintenance.";
    } else if (temp < 20) {
      today = "❄️ Cool Conditions: Crop growth in $loc may slow down due to lower temperatures. Keep an eye out for cold-weather pests and ensure sensitive crops are protected from sudden temperature drops.";
    } else {
      today = "🌱 Stable Conditions: Weather in $loc is stable and clear. It's a great day for routine field scouting, pruning, and general crop maintenance. Keep up with your standard irrigation schedule.";
    }

    // Next Days Outlook (Simple logic based on forecast)
    String outlook = "";
    bool rainIncoming = forecast.take(16).any((w) => (w.weatherDescription ?? "").toLowerCase().contains('rain'));
    bool hotIncoming = forecast.take(16).any((w) => (w.temperature?.celsius ?? 0) > 32);

    if (rainIncoming) {
      outlook = "Next 48H Outlook: Incoming rain detected. Clear your drainage trenches to prevent waterlogging and harvest any mature crops before the fields get too muddy.";
    } else if (hotIncoming) {
      outlook = "Next 48H Outlook: A heatwave is approaching. Ensure your irrigation systems are fully operational and prepare shade nets for sensitive seedlings.";
    } else {
      outlook = "Next 48H Outlook: The weather remains steady. Keep following your standard agricultural calendar and maintenance routines.";
    }

    return "$today\n\nNext days outlook: $outlook";
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() => _dailyNotification = value);
    if (value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily 6AM weather notification enabled!'))
      );
    }
  }

  void _speakSummary() async {
    await _flutterTts.speak(_aiSummary);
  }

  Widget _buildDynamicWeatherGraphic(int? code) {
    final isNight = DateTime.now().hour < 6 || DateTime.now().hour >= 18;
    
    if (code == null || code == 800) {
      if (isNight) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC5CAE9).withOpacity(0.3), // Soft indigo glow
          ),
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8EAF6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9FA8DA).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.nightlight_round, size: 40, color: Color(0xFF5C6BC0)), // Indigo moon
            ),
          ),
        );
      }

      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow[300]!.withOpacity(0.3),
        ),
        child: Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow[600],
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow[400]!.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      child: Text(
        _getWeatherEmoji(code),
        style: const TextStyle(fontSize: 80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(height: 250, color: Colors.white),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                      const SizedBox(height: 20),
                      Container(height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(onPressed: _loadWeatherData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final today = '${DateTime.now().day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][DateTime.now().month-1]}';
    final isNight = DateTime.now().hour < 6 || DateTime.now().hour >= 18;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 220,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isNight 
                      ? const [Color(0xFFC5CAE9), Color(0xFFE8EAF6), Colors.white] // Light indigo for night
                      : const [Color(0xFF81D4FA), Color(0xFFE1F5FE), Colors.white], // Light blue for day
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: FlexibleSpaceBar(
                background: SingleChildScrollView(
                child: Stack(
                  children: [
                    // Dynamic Weather Graphic
                    Positioned(
                      right: -30,
                      top: 10,
                      child: _buildDynamicWeatherGraphic(_currentWeather?.weatherConditionCode),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 60, bottom: 20), // Reduced top padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_locationName, $today',
                            style: const TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currentWeather?.temperature?.celsius?.toStringAsFixed(0) ?? "--"}°C',
                            style: const TextStyle(
                              fontSize: 44, // Reduced from 56
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentWeather?.weatherDescription ?? 'Clear',
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              transform: Matrix4.translationValues(0.0, -10.0, 0.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAiSummaryCard().animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                      _buildNotificationToggle().animate().fade(duration: 500.ms, delay: 200.ms),
                      const Text('Next 5 days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildForecastSection().animate().fade(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      const Text('Spraying time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Best time to spray crops based on weather conditions', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      _buildSprayingSchedule(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFFDF2)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Farming Advisory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              if (_aiSummary.isNotEmpty)
                IconButton(
                  onPressed: _speakSummary,
                  icon: const Icon(Icons.volume_up, color: Color(0xFF1565C0)),
                  tooltip: 'Listen',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_aiSummary, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Text('Get this as a daily notification', style: TextStyle(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Switch(value: _dailyNotification, onChanged: _toggleNotification, activeColor: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    // Group forecast by day starting tomorrow, using formatted calendar keys to avoid month crossover bugs
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final Map<String, List<Weather>> dailyGroups = {};
    
    for (var w in _forecast) {
      if (w.date != null) {
        final dayKey = "${w.date!.year}-${w.date!.month.toString().padLeft(2, '0')}-${w.date!.day.toString().padLeft(2, '0')}";
        // Exclude today and ensure the forecast is in the future
        if (dayKey != todayStr && w.date!.isAfter(now)) {
          dailyGroups.putIfAbsent(dayKey, () => []).add(w);
        }
      }
    }

    final sortedKeys = dailyGroups.keys.toList()..sort();
    final dailyForecasts = sortedKeys.take(5).map((key) {
      final group = dailyGroups[key]!;
      final date = group.first.date!;
      final dayName = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday-1];
      
      // Get max temp and most frequent condition
      double maxTemp = -100;
      int? conditionCode;
      
      for (var w in group) {
        if (w.temperature?.celsius != null && w.temperature!.celsius! > maxTemp) {
          maxTemp = w.temperature!.celsius!;
        }
        conditionCode ??= w.weatherConditionCode;
      }
      
      return _buildForecastDay(
        dayName,
        _getWeatherEmoji(conditionCode),
        '${maxTemp.toStringAsFixed(0)} °C',
        _getWeatherColor(conditionCode),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF81D4FA).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.05)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: dailyForecasts),
      ),
    );
  }

  String _getWeatherEmoji(int? code) {
    final isNight = DateTime.now().hour < 6 || DateTime.now().hour >= 18;
    if (code == null) return isNight ? "🌙" : "☀️";
    if (code == 800) return isNight ? "🌙" : "☀️";
    if (code > 800 && code <= 804) return isNight ? "☁️" : "🌥️";
    if (code >= 500 && code <= 531) return "🌧️";
    if (code >= 600 && code <= 622) return "🌨️";
    if (code >= 200 && code <= 232) return "⛈️";
    if (code >= 700 && code <= 781) return "🌫️";
    return "⛅";
  }

  Color _getWeatherColor(int? code) {
    if (code == null || code == 800) return Colors.yellow[700]!;
    if (code > 800 && code <= 804) return Colors.grey;
    if (code >= 500 && code <= 531) return Colors.blue;
    if (code >= 600 && code <= 622) return Colors.lightBlue[200]!;
    if (code >= 200 && code <= 232) return Colors.blueGrey[800]!;
    if (code >= 700 && code <= 781) return Colors.grey[400]!;
    return Colors.grey;
  }

  Widget _buildSprayingSchedule() {
    final List<Widget> sprayWidgets = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 8; i++) { // Show 8 hours
      final hour = now.add(Duration(hours: i));
      final h = hour.hour == 0 ? 12 : (hour.hour > 12 ? hour.hour - 12 : hour.hour);
      final ampm = hour.hour >= 12 ? 'PM' : 'AM';
      final hourStr = i == 0 ? 'Now' : '$h $ampm';
      
      Weather? hourWeather;
      if (_forecast.isNotEmpty) {
        // Find the forecast record closest to this target hour
        hourWeather = _forecast.reduce((a, b) {
          if (a.date == null) return b;
          if (b.date == null) return a;
          final diffA = a.date!.difference(hour).abs();
          final diffB = b.date!.difference(hour).abs();
          return diffA < diffB ? a : b;
        });
      }
      hourWeather ??= _currentWeather;

      final status = _calculateSprayingStatus(hourWeather);
      sprayWidgets.add(_buildSprayTime(hourStr, status));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF81D4FA).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: sprayWidgets),
          ),
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
  }

  _Status _calculateSprayingStatus(Weather? w) {
    if (w == null) return _Status.moderate;
    final humidity = w.humidity ?? 0;
    final windSpeedKmh = (w.windSpeed ?? 0) * 3.6; // Convert m/s to km/h
    final desc = w.weatherDescription?.toLowerCase() ?? "";
    final isRaining = desc.contains('rain') || desc.contains('drizzle') || desc.contains('storm');
    
    if (isRaining || humidity > 80 || windSpeedKmh >= 15) return _Status.unfavourable;
    if (humidity < 60 && windSpeedKmh < 12) return _Status.optimal;
    return _Status.moderate;
  }

  Widget _buildForecastDay(String day, String emoji, String temp, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSprayTime(String time, _Status status) {
    Color bgColor; Color iconColor; IconData icon;
    switch (status) {
      case _Status.optimal: bgColor = const Color(0xFFE8F5E9); iconColor = const Color(0xFF43A047); icon = Icons.check_circle_outline; break;
      case _Status.moderate: bgColor = const Color(0xFFFFF3E0); iconColor = const Color(0xFFFB8C00); icon = Icons.warning_amber_rounded; break;
      case _Status.unfavourable: bgColor = const Color(0xFFFFEBEE); iconColor = const Color(0xFFE53935); icon = Icons.cancel_outlined; break;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(time, style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildLegendItem('Optimal', _Status.optimal),
          const SizedBox(width: 16),
          _buildLegendItem('Moderate', _Status.moderate),
        ]),
        const SizedBox(height: 12),
        _buildLegendItem('Unfavourable', _Status.unfavourable),
      ],
    );
  }

  Widget _buildLegendItem(String label, _Status status) {
    Color bgColor; Color iconColor; IconData icon;
    switch (status) {
      case _Status.optimal: bgColor = const Color(0xFFE8F5E9); iconColor = const Color(0xFF43A047); icon = Icons.check_circle_outline; break;
      case _Status.moderate: bgColor = const Color(0xFFFFF3E0); iconColor = const Color(0xFFFB8C00); icon = Icons.warning_amber_rounded; break;
      case _Status.unfavourable: bgColor = const Color(0xFFFFEBEE); iconColor = const Color(0xFFE53935); icon = Icons.cancel_outlined; break;
    }
    return Row(children: [
      Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 14)),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
    ]);
  }
}

enum _Status { optimal, moderate, unfavourable }
