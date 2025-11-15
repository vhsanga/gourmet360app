import 'package:Gourmet360/bloc/login/login_event.dart';
import 'package:Gourmet360/bloc/login/login_state.dart';
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
      final usuario = await authRepository.login(event.phone, event.pin);
      emit(LoginSuccess(usuario: usuario));
    } catch (error) {
      emit(LoginFailure(error: error.toString().replaceAll('Exception:', '')));
    }
  }
}
