import 'dart:convert';
import 'package:Gourmet360/core/models/camion_asignado.dart';
import 'package:Gourmet360/core/models/http_response.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class HttpRepository {
  final http.Client client;

  HttpRepository({http.Client? client}) : client = client ?? http.Client();

  Future<HttpResponse> doGet(
    String path,
    Map<String, dynamic> params,
    String userToken,
  ) async {
    final uri = Uri.parse(
      ApiConstants.baseUrl + path,
    ).replace(queryParameters: params);
    final response = await client
        .get(
          uri,
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
      throw Exception('Error consultar información: ${response.statusCode}');
    }
  }

  Future<HttpResponse> doPost(
    String path,
    Map<String, dynamic> params,
    String userToken,
  ) async {
    print("params:");
    print(json.encode(params));
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    final response = await client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: json.encode(params),
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
      throw Exception(
        response.body.isNotEmpty
            ? 'Error al enviar información: ${json.decode(response.body)['mensaje']}'
            : 'Error al enviar información: ${response.statusCode}',
      );
    }
  }
}
