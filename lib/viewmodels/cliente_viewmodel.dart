import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/cliente_admin.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class ClienteViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  String? msj;
  List<ClienteAdmin> clientes = [];

  Future<void> listarClientesForAdmin(String userToken) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await HttpService.doGet(
        ApiConstants.listarClienteEndpoint,
        userToken,
      );

      clientes = (response.data as List)
          .map((e) => ClienteAdmin.fromJson(e))
          .toList();
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
      clientes = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarCliente(String userToken, String clienteId) async {
    isLoading = true;
    msj = null;
    notifyListeners();

    try {
      final response = await HttpService.doPost(
        ApiConstants.eliminarClienteEndpoint,
        {'id': clienteId},
        userToken,
      );
      msj = response.mensaje;
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
