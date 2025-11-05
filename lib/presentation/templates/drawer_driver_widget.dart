import 'package:Gourmet360/presentation/clients_list_screen.dart';
import 'package:Gourmet360/presentation/home_screen.dart';
import 'package:Gourmet360/presentation/user_profile_screen.dart';
import 'package:flutter/material.dart';

class DrawerDriverWidget extends StatefulWidget {
  const DrawerDriverWidget({super.key});

  @override
  State<DrawerDriverWidget> createState() => _DrawerDriverWidgetState();
}

class _DrawerDriverWidgetState extends State<DrawerDriverWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFCF5),
      child: SafeArea(
        child: Column(
          children: [
            // Header del menú
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF6B2A02)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menú',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Opciones del menú
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    title: 'Inicio',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePortalScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Clientes',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientsListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.route_outlined,
                    title: 'Rutas',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Historial',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Mi Perfil',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Ayuda',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Footer del menú
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gourmet360 v1.0.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF5E2C8) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              iconColor ??
              (isSelected ? const Color(0xFF6B2A02) : Colors.grey.shade700),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color:
                textColor ??
                (isSelected ? const Color(0xFF6B2A02) : Colors.grey.shade700),
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.chevron_right, color: Color(0xFF6B2A02))
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
