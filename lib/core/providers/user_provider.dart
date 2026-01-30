import 'package:flutter/material.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/data/services/local_storage_service.dart';

enum UserStatus { initial, loading, loaded, empty, error }

class UserProvider extends ChangeNotifier {
  Usuario? _usuario;
  UserStatus _status = UserStatus.initial;
  String? _errorMessage;

  Usuario? get usuario => _usuario;
  UserStatus get status => _status;
  String? get errorMessage => _errorMessage;

  String? get token => _usuario?.accessToken;

  // =========================
  // Cargar usuario
  // =========================
  Future<void> loadUser() async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      final user = await LocalStorageService.getUser();
      if (user != null) {
        _usuario = user;
        _status = UserStatus.loaded;
      } else {
        _usuario = null;
        _status = UserStatus.empty;
      }
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = 'Error al cargar usuario: $e';
    }

    notifyListeners();
  }

  // =========================
  // Guardar usuario
  // =========================
  Future<void> saveUser(Usuario usuario) async {
    try {
      await LocalStorageService.saveUser(usuario);
      _usuario = usuario;
      _status = UserStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = 'Error al guardar usuario: $e';
      notifyListeners();
    }
  }

  // =========================
  // Logout
  // =========================
  Future<void> logout() async {
    try {
      await LocalStorageService.deleteUser();
      _usuario = null;
      _status = UserStatus.empty;
      notifyListeners();
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = 'Error al eliminar usuario: $e';
      notifyListeners();
    }
  }

  Future<void> setDespacho(int idDespacho) async {
    if (_usuario != null) {
      _usuario!.idDespacho = idDespacho;
      await LocalStorageService.saveUser(_usuario!);
      notifyListeners();
    }
  }
}
