import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/cliente_venta_dia.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/dashboard_despachos.dart';
import 'package:Gourmet360/models/dashboard_ventas.dart';
import 'package:Gourmet360/models/despachos_chofer.dart';
import 'package:Gourmet360/models/producto_restante.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:flutter/material.dart';

class AdminViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? msj;
  String? error;
  DashboardDespachos? dashboardDespachos;
  DashboardVentas? dashboardVentas;
  DespachosChofer? despachosChofer;
  List<ClienteVentas> clientesVentas = [];
  List<ClienteVentaDia> clientesVentaDias = [];
  List<ProductoRestante> productosRestantes = [];

  Future<void> fetchDashboardDataToday(String userToken) async {
    isLoading = true;
    error = null;
    notifyListeners();
    String fecha = CustomUils.fechaActual();
    try {
      final response = await HttpService.doGet(
        ApiConstants.dashboardDataAdminEndpoint + fecha,
        userToken,
      );
      dashboardDespachos = DashboardDespachos.fromJson(
        response.data['despachos'],
      );
      dashboardVentas = DashboardVentas.fromJson(response.data['ventas']);
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getResumenDespachosChoferForAdminEndpoint(
    int idChofer,
    String userToken,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        ApiConstants.getResumenDespachosChoferForAdminEndpoint +
            idChofer.toString(),
        userToken,
      );
      despachosChofer = DespachosChofer.fromJson(
        response.data['despachos'],
        response.data['devoluciones'],
        response.data['ventasHoy'],
        response.data['cuentasPorCobrar'],
      );
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarEntregaDespacho(int choferId, String userToken) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.setDespachoEntregadoForAdminEndpoint + choferId.toString(),
        {},
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

  Future<void> getResumenVentasClientesForAdminEndpoint(
    String fecha,
    String userToken,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        ApiConstants.getResumenVentasClientesForAdminEndpoint + fecha,
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

  Future<void> getResumenVentaClienteDiaRango(
    int idCliente,
    String finicio,
    String ffin,
    String userToken,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.getResumenVentaClienteRangoForAdminEndpoint,
        {'finicio': finicio, 'ffin': ffin, 'idcliente': idCliente},
        userToken,
      );
      clientesVentaDias = (response.data as List<dynamic>)
          .map((e) => ClienteVentaDia.fromJson(e))
          .toList();
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDetalleProductosSobrantes(
    int choferId,
    String userToken,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doGet(
        ApiConstants.getDetalleProductosRestantesForAdminEndpoint +
            choferId.toString(),
        userToken,
      );
      productosRestantes = (response.data as List<dynamic>)
          .map((e) => ProductoRestante.fromJson(e))
          .toList();
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inactivarUsuarioForAdminEndpoint(
    int choferId,
    String userToken,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.inactivarUsuarioForAdminEndpoint,
        {"idusuario": choferId},
        userToken,
      );
      isSuccess = response.ok;
      msj = response.mensaje;
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
