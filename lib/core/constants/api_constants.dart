class ApiConstants {
  static const String baseUrl = 'http://192.168.100.7:3000/api/v1';
  static const String loginEndpoint = '/auth/login';
  static const String usersDataHomeEndPoint = '/usuario/data-home';
  static const String saveVentaEndpoint = '/admin/save-venta';
  static const String saveAsignarProductosEndpoint = '/admin/asignar-productos';
  static const String getProductosForAdminEndpoint = '/admin/productos';
  static const String getCamionesForAdminEndpoint = '/admin/camiones';
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 3000;
}
