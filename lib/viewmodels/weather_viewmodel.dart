import 'package:flutter/foundation.dart';

import '../models/air_quality_model.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import 'view_state.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._weatherService, this._storageService);

  final WeatherService _weatherService;
  final StorageService _storageService;
  final Map<String, Future<WeatherModel>> _locationWeatherCache = {};

  LocationModel? _selectedLocation;
  WeatherModel? _weather;
  AirQualityModel? _airQuality;
  ViewState _state = ViewState.loading;
  String? _errorMessage;

  LocationModel? get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  AirQualityModel? get airQuality => _airQuality;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  String get waktuLokal {
    final time = _weather?.current.time;
    if (time == null) {
      return '--:--';
    }
    final parsedTime = DateTime.tryParse(time);
    if (parsedTime == null) {
      return '--:--';
    }
    return '${parsedTime.hour.toString().padLeft(2, '0')}:'
        '${parsedTime.minute.toString().padLeft(2, '0')}';
  }

  String get zonaWaktu {
    switch (_weather?.timezone) {
      case 'Asia/Jakarta':
      case 'Asia/Pontianak':
        return 'WIB';
      case 'Asia/Makassar':
        return 'WITA';
      case 'Asia/Jayapura':
        return 'WIT';
      default:
        return _weather?.timezoneAbbreviation ?? '';
    }
  }

  String get kutipanWaktu {
    final time = _weather?.current.time;
    final parsedTime = time == null ? null : DateTime.tryParse(time);
    if (parsedTime == null) {
      return '';
    }

    final hour = parsedTime.hour;
    if (hour >= 5 && hour < 10) {
      return 'Pagi datang membawa kesempatan baru.';
    }
    if (hour >= 10 && hour < 15) {
      return 'Siang terik, langkah tetap berarti.';
    }
    if (hour >= 15 && hour < 18) {
      return 'Sore melambat, biarkan hari pulang pelan-pelan.';
    }
    return 'Malam menenangkan, besok kita mulai lagi.';
  }

  Future<WeatherModel> fetchWeatherForLocation(LocationModel location) {
    final key = '${location.latitude},${location.longitude}';
    final cachedWeather = _locationWeatherCache[key];
    if (cachedWeather != null) {
      return cachedWeather;
    }

    final request = _fetchWeatherForLocation(location, key);
    _locationWeatherCache[key] = request;
    return request;
  }

  Future<WeatherModel> _fetchWeatherForLocation(
    LocationModel location,
    String cacheKey,
  ) async {
    try {
      return await _weatherService.fetchWeather(
        location.latitude,
        location.longitude,
      );
    } on Exception {
      _locationWeatherCache.remove(cacheKey);
      rethrow;
    }
  }

  int? get peluangHujanSaatIni {
    final currentWeather = _weather;
    if (currentWeather == null) {
      return null;
    }

    final currentHour = _hourKey(currentWeather.current.time);
    for (final hourly in currentWeather.hourly) {
      if (_hourKey(hourly.time) == currentHour) {
        return hourly.precipitationProbability;
      }
    }
    return null;
  }

  List<HourlyWeather> get jamJamKeDepan {
    final currentWeather = _weather;
    if (currentWeather == null || currentWeather.hourly.isEmpty) {
      return const [];
    }

    final currentHour = _hourKey(currentWeather.current.time);
    var startIndex = currentWeather.hourly.indexWhere(
      (hourly) => _hourKey(hourly.time) == currentHour,
    );
    if (startIndex == -1) {
      startIndex = currentWeather.hourly.indexWhere(
        (hourly) => _hourKey(hourly.time).compareTo(currentHour) >= 0,
      );
    }
    if (startIndex == -1) {
      return const [];
    }

    return currentWeather.hourly.skip(startIndex).take(5).toList();
  }

  Map<String, String> get activityIndex {
    final currentWeather = _weather;
    if (currentWeather == null) {
      return const {
        'Lari sore': 'Data belum tersedia',
        'Jemur': 'Data belum tersedia',
        'Berkendara': 'Data belum tersedia',
        'Ringkasan': 'Data belum tersedia',
      };
    }

    final rainChance = peluangHujanSaatIni;
    final temperature = currentWeather.current.temperature2m;
    final uvIndex = currentWeather.daily.isEmpty
        ? null
        : currentWeather.daily.first.uvIndexMax;

    return {
      'Lari sore': rainChance == null
          ? 'Data belum tersedia'
          : rainChance < 40 && temperature >= 20 && temperature <= 30
          ? 'Ideal'
          : 'Kurang ideal',
      'Jemur': uvIndex == null
          ? 'Data belum tersedia'
          : uvIndex >= 3
          ? 'Baik'
          : 'Kurang optimal',
      'Berkendara': rainChance == null
          ? 'Data belum tersedia'
          : rainChance < 50
          ? 'Lancar'
          : 'Waspada Hujan',
      'Ringkasan': rainChance == null
          ? 'Data belum tersedia'
          : rainChance < 50
          ? 'Nyaman'
          : 'Waspada Hujan',
    };
  }

  Future<void> init() async {
    _setLoading();
    try {
      _selectedLocation =
          await _storageService.getLastLocation() ?? _defaultLocation;
    } on Exception catch (error) {
      _setError(error);
      return;
    }
    await _fetchWeather();
  }

  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _setLoading();
    try {
      await _storageService.saveLastLocation(location);
    } on Exception catch (error) {
      _setError(error);
      return;
    }
    await _fetchWeather();
  }

  Future<void> refresh() async {
    if (_selectedLocation == null) {
      await init();
      return;
    }
    _setLoading();
    await _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final location = _selectedLocation;
    if (location == null) {
      _state = ViewState.empty;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    try {
      final weather = await _weatherService.fetchWeather(
        location.latitude,
        location.longitude,
      );
      final airQuality = await _weatherService.fetchAirQuality(
        location.latitude,
        location.longitude,
      );
      _weather = weather;
      _airQuality = airQuality;
      _state = weather.hourly.isEmpty && weather.daily.isEmpty
          ? ViewState.empty
          : ViewState.success;
      _errorMessage = null;
    } on Exception catch (error) {
      _setError(error);
      return;
    }
    notifyListeners();
  }

  void _setLoading() {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Exception error) {
    _state = ViewState.error;
    _errorMessage = error.toString().replaceFirst('Exception: ', '');
    notifyListeners();
  }

  String _hourKey(String time) {
    return time.length >= 13 ? time.substring(0, 13) : time;
  }

  static const _defaultLocation = LocationModel(
    name: 'Jakarta Selatan',
    admin1: 'DKI Jakarta',
    country: 'Indonesia',
    latitude: -6.26,
    longitude: 106.81,
  );
}
