class LocationModel {
  const LocationModel({
    this.id,
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final int? id;
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      admin1: json['admin1'] as String?,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  factory LocationModel.fromStoredJson(Map<String, dynamic> json) {
    return LocationModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'admin1': admin1,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get subtitle {
    if (admin1 == null || admin1!.isEmpty) {
      return country;
    }
    return '$admin1, $country';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocationModel &&
            latitude == other.latitude &&
            longitude == other.longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
