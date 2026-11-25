import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';

class GeocodingService {
  Future<List<LocationModel>> searchCity(String name) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': name,
      'count': '5',
      'language': 'id',
      'format': 'json',
    });

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('Pencarian kota melewati batas waktu.');
    } on http.ClientException {
      throw Exception('Gagal terhubung ke layanan pencarian kota.');
    }

    if (response.statusCode != 200) {
      throw Exception('Gagal mencari kota (kode HTTP ${response.statusCode}).');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Respons pencarian kota tidak valid.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Respons pencarian kota tidak valid.');
    }

    final results = decoded['results'];
    if (results == null) {
      return [];
    }
    if (results is! List<dynamic>) {
      throw Exception('Data hasil pencarian kota tidak valid.');
    }

    return results.map((item) {
      if (item is! Map<String, dynamic>) {
        throw Exception('Data lokasi dari pencarian tidak valid.');
      }
      return LocationModel.fromJson(item);
    }).toList();
  }
}
