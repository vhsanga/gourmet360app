import 'package:Gourmet360/core/navigation/app_navigator.dart';
import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:Gourmet360/viewmodels/cliente_viewmodel.dart';
import 'package:Gourmet360/viewmodels/auth_viewmodel.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/viewmodels/localtion_viewmodel.dart';
import 'package:Gourmet360/viewmodels/location_chofer_viemodel.dart';
import 'package:Gourmet360/viewmodels/producto_viewmodel.dart';
import 'package:Gourmet360/services/connectivity_service.dart';
import 'package:Gourmet360/services/sync_queue_service.dart';
import 'package:Gourmet360/viewmodels/ventas_viewmodel.dart';
import 'package:Gourmet360/views/admin/admin_dashboard_screen.dart';
import 'package:Gourmet360/views/home_screen.dart';
import 'package:Gourmet360/views/welcome_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const PanaderiaDeliveryApp());
}

class PanaderiaDeliveryApp extends StatelessWidget {
  const PanaderiaDeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ChoferViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ProductoViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => ClienteViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
        ChangeNotifierProvider(create: (_) => LocationChoferViewModel()),
        ChangeNotifierProvider(create: (_) => VentasViewModel()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => SyncQueueService()),
      ],
      child: MaterialApp(
        navigatorKey: AppNavigator.navigatorKey,
        title: 'Gourmet 360',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en', 'US'), const Locale('es', 'ES')],
        theme: AppThemeData.theme,
        home: const AppWrapper(), // Cambiamos WelcomeScreen por AppWrapper
      ),
    );
  }
}

// Widget wrapper que decide qué pantalla mostrar basado en el estado del usuario
class AppWrapper extends StatelessWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, user, __) {
        // Mientras carga, mostramos splash
        if (user.status == UserStatus.initial ||
            user.status == UserStatus.loading) {
          return _buildSplashScreen();
        }

        // Si existe usuario → Home
        if (user.status == UserStatus.loaded) {
          if (user.usuario!.rol == 'admin') {
            if (kIsWeb) {
              return const AdminDashboardScreen();
            }
            return const AdminBiometricGate();
          } else {
            return const HomePortalScreen();
          }
        }

        // Si no hay usuario o hay error → Welcome
        if (user.status == UserStatus.empty ||
            user.status == UserStatus.error) {
          return const WelcomeScreen();
        }

        // Fallback por seguridad
        return const WelcomeScreen();
      },
    );
  }

  // Splash screen temporal mientras se carga el usuario
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppThemeData.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Puedes agregar tu logo aquí
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppThemeData.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Color(0xFFF5E2C8),
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gourmet 360',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppThemeData.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B2A02)),
            ),
            const SizedBox(height: 10),
            Text(
              'Cargando...',
              style: GoogleFonts.montserrat(color: AppThemeData.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminBiometricGate extends StatefulWidget {
  const AdminBiometricGate({super.key});

  @override
  State<AdminBiometricGate> createState() => _AdminBiometricGateState();
}

class _AdminBiometricGateState extends State<AdminBiometricGate> {
  bool _authorized = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final auth = LocalAuthentication();

    if (mounted) setState(() => _checked = false);

    try {
      // Si el dispositivo no tiene ningún bloqueo (huella, PIN, patrón),
      // no hay forma de autenticar localmente: se permite el acceso, ya que
      // el usuario ya inició sesión con sus credenciales.
      final isSupported = await auth.isDeviceSupported();
      if (!isSupported) {
        if (!mounted) return;
        setState(() {
          _authorized = true;
          _checked = true;
        });
        return;
      }

      // biometricOnly: false -> usa huella/rostro si están activos y, si no,
      // cae al PIN / patrón / contraseña del dispositivo.
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Acceso solo para administradores',
        options: const AuthenticationOptions(biometricOnly: false),
      );

      if (!mounted) return;
      setState(() {
        _authorized = didAuthenticate;
        _checked = true;
      });
    } catch (e) {
      debugPrint('Error en autenticación biométrica: $e');
      if (!mounted) return;
      setState(() {
        _authorized = false;
        _checked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_authorized) {
      return const AdminDashboardScreen();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Acceso denegado'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
