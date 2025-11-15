import 'package:Gourmet360/bloc/login/login_bloc.dart';
import 'package:Gourmet360/bloc/login/login_event.dart';
import 'package:Gourmet360/bloc/login/login_state.dart';
import 'package:Gourmet360/bloc/user/user_bloc.dart';
import 'package:Gourmet360/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPinScreen extends StatefulWidget {
  const LoginPinScreen({Key? key}) : super(key: key);

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Mover al siguiente campo
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Mover al campo anterior al borrar
      _pinFocusNodes[index - 1].requestFocus();
    }
  }

  bool _isFormValid() {
    if (_usernameController.text.trim().isEmpty) return false;
    for (var controller in _pinControllers) {
      if (controller.text.isEmpty) return false;
    }
    return true;
  }

  void _handleLogin() async {
    if (!_isFormValid()) {
      _showSnackBar('Por favor completa todos los campos', isError: true);
      return;
    }

    final phone = _usernameController.text;
    final pin = _pinControllers.map((c) => c.text).join();

    final loginBloc = BlocProvider.of<LoginBloc>(context);

    loginBloc.add(LoginSubmitted(phone: phone, pin: pin));

    await for (final state in loginBloc.stream) {
      if (state is LoginLoading) {
        setState(() => _isLoading = true);
      } else if (state is LoginSuccess) {
        setState(() => _isLoading = false);
        context.read<UserBloc>().add(SaveUserEvent(state.usuario));
        _showSnackBar('¡Inicio de sesión exitoso!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePortalScreen()),
        );
        break;
      } else if (state is LoginFailure) {
        setState(() => _isLoading = false);
        _showSnackBar('Error al iniciar sesión: ${state.error}', isError: true);
        break;
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBackButton(),
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildUsernameField(),
                const SizedBox(height: 32),
                _buildPinSection(),
                const SizedBox(height: 40),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildForgotPin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back, color: Color(0xFF6B2A02), size: 28),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF5E2C8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Iniciar Sesión',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B2A02),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu celular y PIN para acceder',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Celular',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B2A02),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _usernameController,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Ingresa tu número de teléfono',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Color(0xFF6B2A02),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFFF5E2C8), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF6B2A02), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PIN de Seguridad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B2A02),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _obscurePin = !_obscurePin;
                });
              },
              icon: Icon(
                _obscurePin
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF6B2A02),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildPinBox(index)),
        ),
        const SizedBox(height: 12),
        Text(
          'Ingresa tu PIN de 6 dígitos',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPinBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _pinControllers[index].text.isNotEmpty
              ? const Color(0xFF6B2A02)
              : const Color(0xFFF5E2C8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _pinControllers[index],
        focusNode: _pinFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        obscureText: _obscurePin,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6B2A02),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            _onPinChanged(index, value);
          });
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    final isValid = _isFormValid();

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isValid && !_isLoading ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B2A02),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: isValid ? 4 : 0,
          shadowColor: const Color(0xFF6B2A02).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 24),
                ],
              ),
      ),
    );
  }

  Widget _buildForgotPin() {
    return Center(
      child: TextButton(
        onPressed: () {
          _showSnackBar(
            'Contacta al administrador para recuperar tu PIN',
            isError: false,
          );
        },
        child: Text(
          '¿Olvidaste tu PIN?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B2A02),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
