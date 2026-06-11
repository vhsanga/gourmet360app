import 'dart:convert';
import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/http_response.dart';
import 'package:Gourmet360/services/cache_service.dart';
import 'package:Gourmet360/services/connectivity_service.dart';
import 'package:Gourmet360/services/sync_queue_service.dart';
import 'package:http/http.dart' as http;

class HttpService {
  /// GET con estrategia cache-first offline:
  /// - Con red: llama a la API, guarda en caché y retorna.
  /// - Sin red o error de red: retorna los datos guardados en caché.
  /// - Sin red y sin caché: lanza excepción.
  static Future<HttpResponse> doGet(
    String path,
    String userToken, {
    bool useCache = true,
  }) async {
    final isOnline = await ConnectivityService.checkNow();

    if (isOnline) {
      try {
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
          if (useCache) {
            await CacheService.save(path, body);
          }
          return HttpResponse.fromMap(body);
        } else {
          throw Exception(
            response.body.isNotEmpty
                ? 'Error: ${json.decode(response.body)['mensaje']}'
                : 'Error: ${response.statusCode}',
          );
        }
      } catch (e) {
        if (useCache) {
          final cached = await CacheService.get(path);
          if (cached != null) return HttpResponse.fromMap(cached);
        }
        rethrow;
      }
    } else {
      if (useCache) {
        final cached = await CacheService.get(path);
        if (cached != null) return HttpResponse.fromMap(cached);
      }
      throw Exception('Sin conexión a internet y sin datos guardados');
    }
  }

  /// POST con soporte de cola offline.
  ///
  /// Si [queueIfOffline] es true y no hay red, la solicitud queda guardada
  /// en [SyncQueueService] y se reintenta automáticamente al recuperar la red.
  /// El ViewModel recibe una respuesta de éxito con mensaje informativo.
  ///
  /// Si [queueIfOffline] es false (por defecto), el comportamiento sin red es
  /// lanzar excepción como siempre (login, admin, GPS, etc.).
  static Future<HttpResponse> doPost(
    String path,
    Map<String, dynamic> params,
    String userToken, {
    bool queueIfOffline = false,
  }) async {
    final isOnline = await ConnectivityService.checkNow();

    if (!isOnline && queueIfOffline) {
      await SyncQueueService.instance.enqueue(path, params, userToken);
      return HttpResponse(
        ok: true,
        statusCode: 200,
        mensaje:
            'Guardado sin conexión — se sincronizará al recuperar la red',
        timestamp: DateTime.now().toIso8601String(),
        data: {},
        idRequest: 0,
      );
    }

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
      return HttpResponse.fromMap(body);
    } else {
      throw Exception(
        response.body.isNotEmpty
            ? 'Error: ${json.decode(response.body)['mensaje']}'
            : 'Error: ${response.statusCode}',
      );
    }
  }
}
