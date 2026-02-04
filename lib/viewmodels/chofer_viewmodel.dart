import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/camion_asignado.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class ChoferViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  String? msj;
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

  Future<bool> registrarConductor(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.saveRegistrarConductorEndpoint,
        params,
        userToken,
      );
      msj = response.mensaje;
      notifyListeners();
      return true;
    } catch (e) {
      msj = e.toString().replaceAll('Exception:', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarCliente(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.saveRegistrarClienteEndpoint,
        params,
        userToken,
      );
      msj = response.mensaje;
      notifyListeners();
      return true;
    } catch (e) {
      msj = e.toString().replaceAll('Exception:', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
