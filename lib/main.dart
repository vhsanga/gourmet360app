import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Gourmet360/presentation/welcome_screen.dart';

void main() {
  runApp(const PanaderiaDeliveryApp());
}

class PanaderiaDeliveryApp extends StatelessWidget {
  const PanaderiaDeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gourmet 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF6B2A02),
        scaffoldBackgroundColor: const Color(0xFFFFFCF5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B2A02),
          secondary: const Color(0xFFF5E2C8),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
