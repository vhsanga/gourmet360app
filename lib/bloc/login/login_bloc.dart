import 'package:Gourmet360/bloc/login/login_event.dart';
import 'package:Gourmet360/bloc/login/login_state.dart';
import 'package:Gourmet360/core/models/usuario.dart';
import 'package:Gourmet360/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      //final usuario = await authRepository.login(event.phone, event.pin);
      final usuarioAdmin = Usuario(
        id: "1",
        nombre: "Wilmen Ivan Guambo",
        rol: "admin",
        celular: "0999999991",
        activo: 1,
        createdAt: "createdAt",
        updatedAt: "updatedAt",
        accessToken: "accessToken",
      );
      final usuario = Usuario(
        id: "2",
        nombre: "Jacobo URquizo",
        rol: "chofer",
        celular: "0979636584",
        activo: 1,
        createdAt: "createdAt",
        updatedAt: "updatedAt",
        accessToken: "accessToken",
      );
      if (event.phone == "0999999991" && event.pin == "123456") {
        emit(LoginSuccess(usuario: usuarioAdmin));
        return;
      } else if (event.phone == "0979636584" && event.pin == "123456") {
        emit(LoginSuccess(usuario: usuario));
        return;
      } else {
        throw Exception("Número de teléfono o PIN incorrecto.");
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString().replaceAll('Exception:', '')));
    }
  }
}
