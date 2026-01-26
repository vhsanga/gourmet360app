// services/user_service.dart
import 'dart:convert';
import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:Gourmet360/models/http_response.dart';

class HttpService {
  static Future<HttpResponse> doGet(String path, String userToken) async {
    final response = await http
        .get(
          Uri.parse(ApiConstants.baseUrl + path),
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

  static Future<HttpResponse> doPost(
    String path,
    Map<String, dynamic> params,
    String userToken,
  ) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    final response = await http
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
            ? 'Error: ${json.decode(response.body)['mensaje']}'
            : 'Error: ${response.statusCode}',
      );
    }
  }
}
