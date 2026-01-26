import 'package:Gourmet360/core/constants/api_constants.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/services/http_service.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  Usuario? usuario;

  Future<bool> login(String user, String pass) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final Map<String, dynamic> params = {'celular': user, 'password': pass};
      final response = await HttpService.doPost(
        ApiConstants.loginEndpoint,
        params,
        '',
      );
      usuario = Usuario.fromJson(
        response.data['user'],
        response.data['access_token'],
      );
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception:', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// LOGOUT
  Future<void> logout(String idUser) async {
    isLoading = true;
    notifyListeners();

    try {
      // 🔹 Llamada a API opcional
      // await _authService.logout(idUser);

      await Future.delayed(const Duration(milliseconds: 500)); // simulación

      usuario = null;
    } catch (e) {
      error = 'Error al cerrar sesión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Helper
  bool get isAuthenticated => usuario != null;
}
