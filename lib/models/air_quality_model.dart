class AirQualityModel {
  const AirQualityModel({required this.usAqi});

  final int usAqi;

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Data "current" kualitas udara tidak valid.');
    }

    final value = current['us_aqi'];
    if (value is! num) {
      throw const FormatException('Nilai "us_aqi" tidak valid.');
    }
    return AirQualityModel(usAqi: value.toInt());
  }

  String get label {
    if (usAqi <= 50) {
      return 'Baik';
    }
    if (usAqi <= 100) {
      return 'Sedang';
    }
    return 'Tidak Sehat';
  }
}
