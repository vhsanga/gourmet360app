import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/core/models/usuario.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        ),
      );

  Future<Usuario> login(String phone, String pin) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {'celular': phone, 'password': pin},
      );
      if (response.data == null || !response.data['ok']) {
        final errorMessage = response.data != null && response.data is Map
            ? response.data['mensaje'] ?? 'Error en el consumo del servicio'
            : 'Error en el consumo del servicio';
        throw Exception(errorMessage);
      }
      final data = response.data['data'];
      Usuario usuario = Usuario.fromJson(data['user'], data['access_token']);
      return usuario;
    } on DioException catch (e) {
      // Captura específicamente errores de Dio
      if (e.response == null) {
        throw Exception(e.message);
      }
      if (!e.response?.data["ok"]) {
        // Extrae el mensaje del cuerpo de la respuesta
        final errorBody = e.response?.data;
        final errorMessage = errorBody is Map
            ? errorBody['mensaje'] ?? 'Error en el consumo del servicio'
            : 'Error en el consumo del servicio';

        throw Exception(errorMessage);
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido: $e');
    }
  }
}
