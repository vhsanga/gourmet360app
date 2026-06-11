class ApiConstants {
  static const String baseUrl = 'http://192.168.1.19:3000/api/v1';
  static const String loginEndpoint = '/auth/login';
  static const String usersDataHomeEndPoint = '/usuario/data-home';
  static const String saveVentaEndpoint = '/admin/save-venta';
  static const String saveAsignarProductosEndpoint = '/admin/create-despacho';
  static const String saveRegistrarConductorEndpoint =
      '/admin/registrar-conductor';
  static const String getProductosForAdminEndpoint = '/admin/productos';
  static const String getCamionesForAdminEndpoint = '/admin/camiones';
  static const String saveRegistrarClienteEndpoint = '/usuario/create-cliente';
  static const String saveEditarClienteEndpoint = '/usuario/update-cliente';
  static const String dashboardDataAdminEndpoint =
      '/admin/dashboard-data-admin/';
  static const String getResumenDespachosChoferForAdminEndpoint =
      '/admin/resumen-despachos-chofer/';
  static const String setDespachoEntregadoForAdminEndpoint =
      '/admin/set-despacho-entregado/';
  static const String getResumenVentasClientesForAdminEndpoint =
      '/admin/resumen-ventas-clientes/';
  static const String saveRegistrarGastoEndpoint =
      '/admin/update-gasto-despacho';
  static const String saveRegistrarUbicacionChoferEndpoint =
      '/usuario/ubicacion/';
  static const String saveDevolucionesClienteEndpoint = '/usuario/devolucion';
  static const String getResumenVentaClienteRangoForAdminEndpoint =
      '/admin/ventas-cliente-rango';
  static const String getDetalleProductosRestantesForAdminEndpoint =
      '/admin/detalle-productos-restantes/';
  static const String inactivarUsuarioForAdminEndpoint =
      '/usuario/inactivar-usuario';
  static const String crearProductoForAdminEndpoint = '/admin/crear-producto';
  static const String getProductosClienteEndpoint =
      '/usuario/consultar-productos-cliente';
  static const String pagarCreditoEndpoint = '/admin/pagar-venta-credito';
  static const String listarClienteEndpoint = '/cliente';
  static const String eliminarClienteEndpoint = '/cliente/eliminar';
  static const String ventaProductoClienteEndpoint =
      '/admin/venta-productos-cliente/';
  static const String eliminarProductoEndpoint = '/admin/eliminar-producto';
  static const String ventasTotalesDiaAdminEndpoint =
      '/admin/ventas-totales-dia';

  static const int connectTimeout = 5000;
  static const int receiveTimeout = 10000;
}
