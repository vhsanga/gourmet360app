import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/despacho.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<ProductoAsignado> productos = [];
  List<Cliente> clientes = [];
  Despacho? despacho;
  bool cerrarSesion = false;

  Future<bool> getDataHome(String idChofer, String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        '${ApiConstants.usersDataHomeEndPoint}?idChofer=$idChofer',
        token,
      );
      clientes = response.data['clientes']
          .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<Cliente>();
      productos = response.data['productos']
          .map((e) => ProductoAsignado.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<ProductoAsignado>();
      despacho = Despacho.fromJson(response.data['despacho']);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
      if (error!.contains('Usuario inactivo')) {
        cerrarSesion = true;
        notifyListeners();
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
