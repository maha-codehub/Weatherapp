import 'dart:convert';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  // Get device location
  Future<Position> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission permanently denied, enable in settings');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Get current city from location
  Future<String> getCurrentCity() async {
    Position position = await getLocation();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks[0].locality ?? "";
  }

  // Fetch weather data
  Future<Weather> getWeather(String cityName) async {
    final url = Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);

      // Log status code and response body
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Weather Data: $data');
        return Weather.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid API key. Check your OpenWeather API key and restrictions.');
      } else if (response.statusCode == 404) {
        throw Exception('City not found: $cityName');
      } else {
        throw Exception(
            'Failed to load weather data. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error fetching weather data: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load weather data: $e');
    }
  }
}
