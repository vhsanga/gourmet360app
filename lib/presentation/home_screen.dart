import 'package:Gourmet360/presentation/templates/drawer_driver_widget.dart';
import 'package:flutter/material.dart';
import 'package:Gourmet360/presentation/productos_inventory_screen.dart';
import 'package:Gourmet360/presentation/user_profile_screen.dart';

class HomePortalScreen extends StatefulWidget {
  const HomePortalScreen({Key? key}) : super(key: key);

  @override
  State<HomePortalScreen> createState() => _HomePortalScreenState();
}

class _HomePortalScreenState extends State<HomePortalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Delivery> pendingDeliveries = [
    Delivery(
      id: '001',
      client: 'Minimarket La Favorita',
      address: 'Av. la prensa y reina pacha',
      products: 12,
      status: DeliveryStatus.pending,
      time: '08:30 AM',
    ),
    Delivery(
      id: '002',
      client: 'Supermercado La dolorosa',
      address: 'Calle García Moreno 234',
      products: 25,
      status: DeliveryStatus.inProgress,
      time: '09:15 AM',
    ),
    Delivery(
      id: '003',
      client: 'Restaurant El Buen Sabor',
      address: 'Av. 12 de Octubre y Chile',
      products: 8,
      status: DeliveryStatus.pending,
      time: '10:00 AM',
    ),
  ];

  int completedToday = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: DrawerDriverWidget(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Entregas Pendientes'),
                      const SizedBox(height: 16),
                      _buildDeliveryList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF6B2A02),
        icon: const Icon(Icons.route, color: Colors.white),
        label: const Text(
          'Ver Ruta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B2A02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E2C8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Color(0xFF6B2A02),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Buen día, Jacobo!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Martes, 28 de Octubre',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            value: '$completedToday',
            label: 'Completos',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_outlined,
            value: '${pendingDeliveries.length}',
            label: 'Pendientes',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsInventoryScreen(),
                ),
              );
            },
            child: _buildStatCard(
              icon: Icons.bakery_dining_rounded,
              value: '1650',
              label: 'Productos',
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E2C8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B2A02),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF6B2A02).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B2A02),
      ),
    );
  }

  Widget _buildDeliveryList() {
    return Column(
      children: pendingDeliveries
          .map((delivery) => _buildDeliveryCard(delivery))
          .toList(),
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: delivery.status == DeliveryStatus.inProgress
              ? const Color(0xFF6B2A02)
              : Colors.transparent,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: delivery.status == DeliveryStatus.inProgress
                      ? const Color(0xFF6B2A02)
                      : const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  delivery.status == DeliveryStatus.inProgress
                      ? 'EN RUTA'
                      : 'PENDIENTE',
                  style: TextStyle(
                    color: delivery.status == DeliveryStatus.inProgress
                        ? Colors.white
                        : const Color(0xFF6B2A02),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                delivery.time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B2A02),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            delivery.client,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B2A02),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  delivery.address,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${delivery.products} productos',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B2A02),
                    side: const BorderSide(color: Color(0xFF6B2A02)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B2A02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

enum DeliveryStatus { pending, inProgress, completed }

class Delivery {
  final String id;
  final String client;
  final String address;
  final int products;
  final DeliveryStatus status;
  final String time;

  Delivery({
    required this.id,
    required this.client,
    required this.address,
    required this.products,
    required this.status,
    required this.time,
  });
}
