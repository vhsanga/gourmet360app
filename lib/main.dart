import 'package:Gourmet360/bloc/user/user_bloc.dart';
import 'package:Gourmet360/presentation/home_screen.dart';
import 'package:Gourmet360/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const PanaderiaDeliveryApp());
}

class PanaderiaDeliveryApp extends StatelessWidget {
  const PanaderiaDeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc()..add(LoadUserEvent()),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Gourmet 360',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          primaryColor: const Color(0xFF6B2A02),
          scaffoldBackgroundColor: const Color(0xFFFFFCF5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B2A02),
            secondary: const Color(0xFFF5E2C8),
          ),
          useMaterial3: true,
        ),
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
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // Mientras carga, mostramos un splash screen temporal
        if (state is UserInitial || state is UserLoading) {
          return _buildSplashScreen();
        }

        // Si existe usuario, vamos al HomeScreen
        if (state is UserLoaded) {
          return HomePortalScreen();
        }

        // Si no existe usuario o hay error, mostramos WelcomeScreen
        if (state is UserEmpty || state is UserError) {
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
      backgroundColor: const Color(0xFFFFFCF5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Puedes agregar tu logo aquí
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6B2A02),
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
                color: const Color(0xFF6B2A02),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B2A02)),
            ),
            const SizedBox(height: 10),
            Text(
              'Cargando...',
              style: GoogleFonts.montserrat(color: const Color(0xFF6B2A02)),
            ),
          ],
        ),
      ),
    );
  }
}
