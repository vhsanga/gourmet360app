import 'dart:convert';
import 'package:Gourmet360/core/models/cliente.dart';
import 'package:Gourmet360/core/models/producto_asignados.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class HomeRepository {
  final http.Client client;

  HomeRepository({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchClientes({required String idChofer}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/usuario/data-home/?idChofer=$idChofer',
    );
    final response = await client
        .get(uri)
        .timeout(
          const Duration(milliseconds: ApiConstants.receiveTimeout),
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data == null) return {};

      List<Cliente> clientes = data['clientes']
          .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<Cliente>();
      List<ProductoAsignado> productos = data['productos']
          .map((e) => ProductoAsignado.fromJson(e as Map<String, dynamic>))
          .toList()
          .cast<ProductoAsignado>();
      Map<String, dynamic> responseData = {
        'clientes': clientes,
        'productos': productos,
      };
      return responseData;
    } else {
      throw Exception('Failed to load clientes: ${response.statusCode}');
    }
  }
}
