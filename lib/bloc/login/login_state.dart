import 'package:Gourmet360/core/models/usuario.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Usuario usuario;

  LoginSuccess({required this.usuario});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
