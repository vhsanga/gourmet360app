import 'package:Gourmet360/bloc/user/user_bloc.dart';
import 'package:Gourmet360/presentation/admin/cliente_report_screen.dart';
import 'package:Gourmet360/presentation/admin/despacho_screen.dart';
import 'package:Gourmet360/presentation/admin/drivers_list_screen.dart';
import 'package:Gourmet360/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Datos del dashboard
  final int totalDrivers = 8;
  final int activeDrivers = 6;

  final int totalProducts = 2850;
  final int soldProducts = 1847;

  final double totalRevenue = 3254.75;
  final double todayRevenue = 1847.50;

  final double accountsReceivable = 1580.00;

  final int rejectedProducts = 23;
  final int damagedProducts = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Productos y Ventas'),
                    const SizedBox(height: 12),
                    _buildProductsCard(),
                    const SizedBox(height: 12),
                    _buildRevenueCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Finanzas'),
                    const SizedBox(height: 12),
                    _buildAccountsReceivableCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Control de Calidad'),
                    const SizedBox(height: 12),
                    _buildQualityControlCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: const Color(0xFF6B2A02),

      // 👉 ACTIONS: Menú 3 puntos
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: Colors.white,
          onSelected: (value) {
            if (value == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriversListScreen()),
              );
            } else if (value == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientsReportScreen()),
              );
            } else if (value == 3) {
              context.read<UserBloc>().add(DeleteUserEvent());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Row(
                children: const [
                  Icon(Icons.local_shipping_outlined, color: Color(0xFF6B2A02)),
                  SizedBox(width: 10),
                  Text("Conductores"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: const [
                  Icon(Icons.bar_chart, color: Color(0xFF6B2A02)),
                  SizedBox(width: 10),
                  Text("Reportes"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Cerrar Sesión"),
                ],
              ),
            ),
          ],
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E2C8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Color(0xFF6B2A02),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '¡Hola, Admin!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B2A02),
            const Color(0xFF6B2A02).withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2A02).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Resumen del Día',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  'Recaudado',
                  '\$${todayRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  'Vendidos',
                  '$soldProducts',
                  Icons.shopping_cart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF5E2C8), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: const Color(0xFFF5E2C8)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6B2A02),
      ),
    );
  }

  Widget _buildDriversCard() {
    final percentage = (activeDrivers / totalDrivers * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF6B2A02),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transportistas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B2A02),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activeDrivers de $totalDrivers activos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: activeDrivers / totalDrivers,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDriverStat('Activos', activeDrivers, Colors.green),
              _buildDriverStat(
                'Inactivos',
                totalDrivers - activeDrivers,
                Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStat(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsCard() {
    final percentage = (soldProducts / totalProducts * 100);
    final remaining = totalProducts - soldProducts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.blue.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B2A02),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total vs Vendidos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProductStat(
                  'Total',
                  totalProducts.toString(),
                  Icons.all_inbox,
                  Colors.blue.shade700,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade200),
              Expanded(
                child: _buildProductStat(
                  'Vendidos',
                  soldProducts.toString(),
                  Icons.check_circle,
                  Colors.green.shade700,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade200),
              Expanded(
                child: _buildProductStat(
                  'Restantes',
                  remaining.toString(),
                  Icons.pending,
                  Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: soldProducts / totalProducts,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}% vendido',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B2A02),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recaudación de Ventas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${todayRevenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsReceivableCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.schedule,
              color: Colors.orange.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuentas por Cobrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B2A02),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pendientes para mañana',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${accountsReceivable.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityControlCard() {
    final totalIssues = rejectedProducts + damagedProducts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productos con Problemas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B2A02),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: $totalIssues unidades',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.red.shade700,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rejectedProducts.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'Rechazados',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        damagedProducts.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        'Dañados',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
