import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/air_quality_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeather(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,is_day',
      'hourly': 'temperature_2m,weather_code,precipitation_probability',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max,sunset',
      'timezone': 'auto',
      'forecast_days': '5',
    });

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Permintaan data cuaca melewati batas waktu.');
    } on http.ClientException {
      throw Exception('Gagal terhubung ke layanan cuaca.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data cuaca (kode HTTP ${response.statusCode}).',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Respons data cuaca tidak valid.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Respons data cuaca tidak valid.');
    }

    try {
      return WeatherModel.fromJson(decoded);
    } on FormatException {
      throw Exception(
        'Data cuaca dari layanan tidak lengkap atau tidak valid.',
      );
    }
  }

  Future<AirQualityModel?> fetchAirQuality(double lat, double lon) async {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': 'us_aqi',
      'timezone': 'auto',
    });

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      return null;
    } on http.ClientException {
      return null;
    }

    if (response.statusCode != 200) {
      return null;
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return AirQualityModel.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }
}
