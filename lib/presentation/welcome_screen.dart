import 'package:Gourmet360/presentation/home_screen.dart';
import 'package:Gourmet360/presentation/login_pin_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B2A02),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Logo/Nombre de la app
                      Text(
                        'Gourmet360',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFFCF5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Icono
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E2C8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bakery_dining_rounded,
                          size: 70,
                          color: Color(0xFF6B2A02),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Frase
                      Text(
                        'Gestión de entregas con sabor artesanal',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFFF5E2C8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Botón Comenzar
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navegar a la siguiente pantalla
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPinScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFCF5),
                            foregroundColor: const Color(0xFF6B2A02),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Comenzar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, size: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Indicador versión (opcional)
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5E2C8).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
