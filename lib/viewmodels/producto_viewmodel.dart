import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/producto.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class ProductoViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? msj;
  String? error;
  List<Producto> productos = [];
  List<ProductoAsignado> productosAsignados = [];

  Future<bool> entregarProductos(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.saveVentaEndpoint,
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

  Future<bool> asignarProductos(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.saveAsignarProductosEndpoint,
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

  Future<bool> listarProductosForAdmin(String userToken) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        ApiConstants.getProductosForAdminEndpoint,
        userToken,
      );
      msj = response.mensaje;
      productos = response.data
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<Producto>();
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

  Future<bool> listarProductosCliente(
    int idChofer,
    int idCliente,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.getProductosClienteEndpoint,
        {'idChofer': idChofer, 'idCliente': idCliente},
        userToken,
      );
      msj = response.mensaje;
      productosAsignados = response.data['productos']
          .map((e) => ProductoAsignado.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<ProductoAsignado>();
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
