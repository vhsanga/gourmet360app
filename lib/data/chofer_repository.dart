import 'dart:convert';
import 'package:Gourmet360/core/models/http_response.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class ChoferRepository {
  final http.Client client;

  ChoferRepository({http.Client? client}) : client = client ?? http.Client();

  Future<HttpResponse> saveEntregaProductos(
    Map<String, dynamic> params,
    String userToken,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/admin/save-venta');
    final response = await client
        .post(
          uri,
          body: json.encode(params),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
        )
        .timeout(
          const Duration(milliseconds: ApiConstants.receiveTimeout),
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> body =
          json.decode(response.body) as Map<String, dynamic>;
      final res = HttpResponse.fromMap(body);
      return res;
    } else {
      throw Exception('Error la guardar la venta: ${response.statusCode}');
    }
  }
}
