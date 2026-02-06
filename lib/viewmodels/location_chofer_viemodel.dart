import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/camion_asignado.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationChoferViewModel extends ChangeNotifier {
  List<CamionAsignado> _camiones = [];
  Set<Marker> _markers = {};
  bool _isLoadingMap = false;

  // Getters
  Set<Marker> get markers => _markers;
  bool get isLoadingMap => _isLoadingMap;

  Future<void> consultarUbicaciones(String userToken) async {
    _isLoadingMap = true;
    notifyListeners();

    try {
      final response = await HttpService.doGet(
        ApiConstants.getUbicacionChoferEndpoint,
        userToken,
      );
      _camiones = (response.data as List)
          .map((e) => CamionAsignado.fromJson(e))
          .toList();

      // Transformar modelos en Marcadores de Google Maps
      _markers = _camiones.map((camion) {
        return Marker(
          markerId: MarkerId(camion.camionId.toString()),
          position: LatLng(camion.latitud, camion.longitud),
          infoWindow: InfoWindow(
            title: camion.uNombre,
            snippet: camion.uCelular,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        );
      }).toSet();
    } catch (e) {
      print("Error cargando camiones: $e");
    } finally {
      _isLoadingMap = false;
      notifyListeners();
    }
  }
}
