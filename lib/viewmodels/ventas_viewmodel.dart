import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/venta_producto.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class VentasViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? msj;
  String? error;
  List<VentaProducto> productosVendidos = [];
  List<VentaProducto> productosCortesia = [];
  List<VentaProducto> productosDevueltos = [];

  Future<bool> listarVentaProductosFecha(
    String idCliente,
    String fecha,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        '${ApiConstants.ventaProductoClienteEndpoint}$idCliente/$fecha',
        userToken,
      );
      msj = response.mensaje;
      productosVendidos = response.data["ventas"]
          .map((e) => VentaProducto.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<VentaProducto>();
      productosCortesia = response.data["cortesias"]
          .map((e) => VentaProducto.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<VentaProducto>();
      productosDevueltos = response.data["devoluciones"]
          .map((e) => VentaProducto.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<VentaProducto>();
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
