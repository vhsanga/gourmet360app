import 'package:Gourmet360/presentation/admin/drivers_list_screen.dart';
import 'package:Gourmet360/presentation/clients_list_screen.dart';
import 'package:Gourmet360/presentation/home_screen.dart';
import 'package:Gourmet360/presentation/user_profile_screen.dart';
import 'package:flutter/material.dart';

class DrawerAdminWidget extends StatefulWidget {
  const DrawerAdminWidget({super.key});

  @override
  State<DrawerAdminWidget> createState() => _DrawerAdminWidgetState();
}

class _DrawerAdminWidgetState extends State<DrawerAdminWidget> {
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
                        'Menú Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.people_outline,
                    title: 'Transportistas',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriversListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.inventory_outlined,
                    title: 'Productos',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.group_outlined,
                    title: 'Clientes',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.assessment_outlined,
                    title: 'Reportes',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () => Navigator.pop(context),
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
