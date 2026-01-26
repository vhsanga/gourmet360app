import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/camion_asignado.dart';
import 'package:Gourmet360/models/producto.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class ChoferViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? msj;
  String? error;
  List<CamionAsignado> camiones = [];

  Future<bool> listarProductosForAdmin(String userToken) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        ApiConstants.getCamionesForAdminEndpoint,
        userToken,
      );
      msj = response.mensaje;
      print("Respuesta recibida: ${response.data}");
      camiones = response.data
          .map((e) => CamionAsignado.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<CamionAsignado>();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
