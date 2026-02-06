import 'dart:async';
import 'package:Gourmet360/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;
  Function(double lat, double lng)? onLocationChanged;
  Position? _currentPosition;
  String _errorMessage = '';
  Position? get currentPosition => _currentPosition;
  String get errorMessage => _errorMessage;
  bool _isFetchingSingleLocation = false;
  bool get isFetchingSingleLocation => _isFetchingSingleLocation;

  void startTracking({Function(double lat, double lng)? onLocationChanged}) {
    if (_positionSubscription != null) return;

    this.onLocationChanged = onLocationChanged;
    _positionSubscription = _locationService.getLocationStream().listen(
      (Position position) {
        _currentPosition = position;

        if (this.onLocationChanged != null) {
          this.onLocationChanged!(position.latitude, position.longitude);
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<Position?> getPositionOnce() async {
    _isFetchingSingleLocation = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final position = await _locationService.getSingleCurrentLocation();
      _isFetchingSingleLocation = false;
      notifyListeners();
      return position;
    } catch (e) {
      _errorMessage = e.toString();
      _isFetchingSingleLocation = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
