abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String phone;
  final String pin;

  LoginSubmitted({required this.phone, required this.pin});
}
