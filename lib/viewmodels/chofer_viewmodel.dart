import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/camion_asignado.dart';
import 'package:Gourmet360/models/producto.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class ChoferViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<CamionAsignado> camiones = [];

  Future<void> listarProductosForAdmin(String userToken) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await HttpService.doGet(
        ApiConstants.getCamionesForAdminEndpoint,
        userToken,
      );

      camiones = (response.data as List)
          .map((e) => CamionAsignado.fromJson(e))
          .toList();
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
      camiones = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
