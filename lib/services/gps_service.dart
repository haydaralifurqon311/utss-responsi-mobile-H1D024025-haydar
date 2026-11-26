import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

enum GpsErrorType {
  locationServiceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unavailable,
}

class GpsServiceException implements Exception {
  const GpsServiceException(this.type, this.message);

  final GpsErrorType type;
  final String message;

  @override
  String toString() => message;
}

class GpsService {
  Future<LocationModel> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const GpsServiceException(
        GpsErrorType.locationServiceDisabled,
        'Layanan lokasi mati. Aktifkan GPS untuk melanjutkan.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const GpsServiceException(
        GpsErrorType.permissionDeniedForever,
        'Izin lokasi ditolak permanen. Ubah izin aplikasi di pengaturan.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const GpsServiceException(
        GpsErrorType.permissionDenied,
        'Izin lokasi ditolak.',
      );
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw const GpsServiceException(
        GpsErrorType.timeout,
        'Waktu mendapatkan lokasi habis. Coba lagi.',
      );
    } on LocationServiceDisabledException {
      throw const GpsServiceException(
        GpsErrorType.locationServiceDisabled,
        'Layanan lokasi mati. Aktifkan GPS untuk melanjutkan.',
      );
    } on PermissionDeniedException {
      throw const GpsServiceException(
        GpsErrorType.permissionDenied,
        'Izin lokasi ditolak.',
      );
    } on Exception {
      throw const GpsServiceException(
        GpsErrorType.unavailable,
        'Lokasi perangkat tidak dapat diperoleh. Coba lagi.',
      );
    }

    var name = 'Lokasi Saya';
    String? admin1;
    var country = '';
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final locality = placemark.locality?.trim();
        final subAdministrativeArea = placemark.subAdministrativeArea?.trim();
        name = locality?.isNotEmpty == true
            ? locality!
            : subAdministrativeArea?.isNotEmpty == true
            ? subAdministrativeArea!
            : name;
        admin1 = placemark.administrativeArea?.trim();
        if (admin1?.isEmpty == true) {
          admin1 = null;
        }
        country = placemark.country?.trim() ?? '';
      }
    } on Exception {
      // Nama koordinat tetap dipakai kalau reverse geocoding gagal.
    }

    return LocationModel(
      name: name,
      admin1: admin1,
      country: country,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }
}
