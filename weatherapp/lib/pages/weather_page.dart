import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('332d7ab2974df6daa481715df4955fa4');
  Weather? _weather;

  // Fetch weather data
  Future<void> _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // FIXED: Always return a valid animation
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/windy.json';

      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/partlyshower.json';

      case 'thunderstorm':
        return 'assets/storm.json';

      case 'clear':
        return 'assets/sunny.json';

      default:
        return 'assets/sunny.json';   // <-- REQUIRED FIX
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather(); // Fetch weather when page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weather?.cityName ?? "Loading city...",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),

            Text(
              _weather != null
                  ? '${_weather!.temperature.round()}°C'
                  : 'Loading temperature...',
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),

            // Lottie animation
            Lottie.asset(
              getWeatherAnimation(_weather?.mainCondition),
              width: 200,
              height: 200,
            ),

            Text(
              _weather?.mainCondition ?? "",
              style: TextStyle(color: Colors.white, fontSize: 22),
            )
          ],
        ),
      ),
    );
  }
}
