import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/geocoding_service.dart';
import '../services/gps_service.dart';
import '../services/storage_service.dart';
import 'view_state.dart';

enum LocationFilter { semua, favorit }

class LocationViewModel extends ChangeNotifier {
  LocationViewModel(
    this._geocodingService,
    this._storageService,
    this._gpsService,
  );

  final GeocodingService _geocodingService;
  final StorageService _storageService;
  final GpsService _gpsService;

  String _query = '';
  List<LocationModel> _results = [];
  List<LocationModel> _favorites = [];
  List<String> _history = [];
  ViewState _state = ViewState.empty;
  String? _errorMessage;
  LocationFilter _filter = LocationFilter.semua;
  bool _isLocating = false;
  GpsServiceException? _gpsError;

  String get query => _query;
  List<LocationModel> get results => List.unmodifiable(_results);
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<String> get history => List.unmodifiable(_history);
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  LocationFilter get filter => _filter;
  bool get isLocating => _isLocating;
  GpsServiceException? get gpsError => _gpsError;

  List<LocationModel> get visibleLocations {
    if (_filter == LocationFilter.semua) {
      return results;
    }
    if (_query.isEmpty) {
      return favorites;
    }

    final normalizedQuery = _query.toLowerCase();
    return _favorites
        .where(
          (location) =>
              location.name.toLowerCase().contains(normalizedQuery) ||
              location.country.toLowerCase().contains(normalizedQuery) ||
              (location.admin1?.toLowerCase().contains(normalizedQuery) ??
                  false),
        )
        .toList();
  }

  Future<void> init() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await _storageService.getFavorites();
      _history = await _storageService.getSearchHistory();
      _state = ViewState.empty;
    } on Exception catch (error) {
      _setError(error);
      return;
    }
    notifyListeners();
  }

  Future<void> search(String value) async {
    _query = value.trim();
    _results = [];
    _errorMessage = null;
    if (_query.isEmpty) {
      _state = ViewState.empty;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();
    try {
      _results = await _geocodingService.searchCity(_query);
      _history = [
        _query,
        ..._history.where((search) => search != _query),
      ].take(5).toList();
      await _storageService.saveSearchHistory(_history);
      _state = _results.isEmpty ? ViewState.empty : ViewState.success;
    } on Exception catch (error) {
      _setError(error);
      return;
    }
    notifyListeners();
  }

  bool isFavorite(LocationModel location) {
    return _favorites.contains(location);
  }

  Future<void> toggleFavorite(LocationModel location) async {
    final updatedFavorites = List<LocationModel>.from(_favorites);
    if (updatedFavorites.contains(location)) {
      updatedFavorites.remove(location);
    } else {
      updatedFavorites.add(location);
    }

    await _storageService.saveFavorites(updatedFavorites);
    _favorites = updatedFavorites;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.saveSearchHistory([]);
    _history = [];
    notifyListeners();
  }

  Future<GpsServiceException?> useCurrentLocation({
    required Future<void> Function(LocationModel) onLocationSelected,
  }) async {
    _isLocating = true;
    _gpsError = null;
    notifyListeners();

    try {
      final location = await _gpsService.getCurrentLocation();
      await onLocationSelected(location);
      return null;
    } on GpsServiceException catch (error) {
      _gpsError = error;
      return error;
    } on Exception {
      const error = GpsServiceException(
        GpsErrorType.unavailable,
        'Lokasi perangkat tidak dapat diperoleh. Coba lagi.',
      );
      _gpsError = error;
      return error;
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<bool> openLocationSettings() {
    return _gpsService.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return _gpsService.openAppSettings();
  }

  void setFilter(LocationFilter filter) {
    if (_filter == filter) {
      return;
    }
    _filter = filter;
    notifyListeners();
  }

  void _setError(Exception error) {
    _state = ViewState.error;
    _errorMessage = error.toString().replaceFirst('Exception: ', '');
    notifyListeners();
  }
}
