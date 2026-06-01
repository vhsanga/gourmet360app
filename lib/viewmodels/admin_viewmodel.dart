import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/cliente_venta_dia.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/cortesias.dart';
import 'package:Gourmet360/models/dashboard_despachos.dart';
import 'package:Gourmet360/models/dashboard_ventas.dart';
import 'package:Gourmet360/models/despachos_chofer.dart';
import 'package:Gourmet360/models/devoluciones.dart';
import 'package:Gourmet360/models/gastos.dart';
import 'package:Gourmet360/models/producto_restante.dart';
import 'package:Gourmet360/models/ventas_totales_dia.dart';
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
  List<Gasto> gastos = [];
  List<Cortesias> cortesias = [];
  List<Devoluciones> devoluciones = [];
  List<ClienteVentas> clientesVentas = [];
  List<ClienteVentaDia> clientesVentaDias = [];
  List<ProductoRestante> productosRestantes = [];
  List<VentasTotalesDia> ventasTotalesDias = [];

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

  Future<void> fetchVentasTotalesDia(String userToken) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await HttpService.doGet(
        ApiConstants.ventasTotalesDiaAdminEndpoint,
        userToken,
      );
      ventasTotalesDias = (response.data as List<dynamic>)
          .map((e) => VentasTotalesDia.fromJson(e))
          .toList();
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
        response.data['ventasHoy'],
        response.data['cuentasPorCobrar'],
      );
      gastos = (response.data['gastos'] as List<dynamic>)
          .map((e) => Gasto.fromJson(e))
          .toList();
      cortesias = (response.data['cortesias'] as List<dynamic>)
          .map((e) => Cortesias.fromJson(e))
          .toList();
      devoluciones = (response.data['devoluciones'] as List<dynamic>)
          .map((e) => Devoluciones.fromJson(e))
          .toList();
      print(
        'Gastos: ${gastos.length}, Cortesias: ${cortesias.length}, Devoluciones: ${devoluciones.length}',
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

  Future<bool> crearProductoForAdminEndpoint(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.crearProductoForAdminEndpoint,
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

  Future<bool> cobrarDeuda(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    isLoading = true;
    msj = null;
    notifyListeners();
    try {
      final response = await HttpService.doPost(
        ApiConstants.pagarCreditoEndpoint,
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
