import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/camion_asignado.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class ChoferViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  String? msj;
  List<CamionAsignado> camiones = [];
  List<ClienteVentas> clientesVentas = [];

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

  Future<bool> registrarGastoDespacho(
    double gastos,
    int despachoId,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      Map<String, dynamic> params = {"gastos": gastos};
      final response = await HttpService.doPost(
        ApiConstants.saveRegistrarGastoEndpoint + despachoId.toString(),
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

  Future<bool> registrarUbicacionChofer(
    double lat,
    double lng,
    int idChofer,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      Map<String, dynamic> params = {
        "lat": lat,
        "lng": lng,
        "idChofer": idChofer,
      };
      final response = await HttpService.doPost(
        ApiConstants.saveRegistrarUbicacionChoferEndpoint,
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

  Future<void> getResumenVentasClientesForChoferEndpoint(
    String userToken,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        ApiConstants.getResumenVentasClientesForAdminEndpoint +
            CustomUils.fechaActual(),
        userToken,
      );
      clientesVentas = (response.data as List<dynamic>)
          .map((e) => ClienteVentas.fromJson(e))
          .toList();
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarDevolucionCliente(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.saveDevolucionesClienteEndpoint,
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
