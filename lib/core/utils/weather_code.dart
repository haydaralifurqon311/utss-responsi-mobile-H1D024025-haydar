import 'package:flutter/material.dart';

String weatherCodeToText(int code) {
  if (code == 0) return 'Cerah';
  if (code == 1) return 'Cerah Berawan';
  if (code == 2) return 'Berawan Sebagian';
  if (code == 3) return 'Berawan Tebal';
  if (code == 45 || code == 48) return 'Berkabut';
  if (code >= 51 && code <= 57) return 'Gerimis';
  if (code == 61) return 'Hujan Ringan';
  if (code == 63) return 'Hujan Sedang';
  if (code == 65) return 'Hujan Lebat';
  if (code == 66 || code == 67) return 'Hujan Beku';
  if (code >= 71 && code <= 77) return 'Salju';
  if (code == 80) return 'Hujan Ringan Sesaat';
  if (code == 81) return 'Hujan Sedang Sesaat';
  if (code == 82) return 'Hujan Petir Sore';
  if (code == 95) return 'Badai Petir';
  if (code == 96 || code == 99) return 'Badai Petir Disertai Es';
  return 'Kondisi cuaca tidak diketahui';
}

IconData weatherCodeToIcon(int code, {bool isDay = true}) {
  if (code == 0) {
    return isDay ? Icons.wb_sunny : Icons.nights_stay;
  }
  if (code == 1 || code == 2) {
    return isDay ? Icons.wb_cloudy : Icons.cloud_queue;
  }
  if (code == 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.blur_on;
  if (code >= 51 && code <= 57) return Icons.grain;
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
    return Icons.water_drop;
  }
  if (code >= 71 && code <= 77) return Icons.ac_unit;
  if (code == 95 || code == 96 || code == 99) {
    return Icons.thunderstorm;
  }
  return Icons.help_outline;
}
