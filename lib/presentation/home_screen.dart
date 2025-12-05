import 'package:Gourmet360/bloc/home/home_bloc.dart';
import 'package:Gourmet360/bloc/home/home_event.dart';
import 'package:Gourmet360/bloc/home/home_state.dart';
import 'package:Gourmet360/bloc/user/user_bloc.dart';
import 'package:Gourmet360/core/models/cliente.dart';
import 'package:Gourmet360/core/models/producto_asignados.dart';
import 'package:Gourmet360/data/home_repository.dart'; // added import
import 'package:Gourmet360/presentation/entrega_producto_screen.dart';
import 'package:Gourmet360/presentation/templates/drawer_driver_widget.dart';
import 'package:flutter/material.dart';
import 'package:Gourmet360/presentation/productos_inventory_screen.dart';
import 'package:Gourmet360/presentation/user_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePortalScreen extends StatefulWidget {
  const HomePortalScreen({Key? key}) : super(key: key);

  @override
  State<HomePortalScreen> createState() => _HomePortalScreenState();
}

class _HomePortalScreenState extends State<HomePortalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> dataHome = {};
  List<Cliente> clientes = [];
  List<ProductoAsignado> productos = [];

  int completedToday = 8;

  @override
  void initState() {
    super.initState();
    // Removed direct dispatch here — HomeBloc will be created and dispatched in build via BlocProvider
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   try {
    //     context.read<HomeBloc>().add(LoadClientes('5'));
    //   } catch (_) {}
    // });
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;

    // Provide HomeBloc here so BlocListener can find it
    return BlocProvider<HomeBloc>(
      create: (context) =>
          HomeBloc(repository: HomeRepository())..add(LoadClientes('5')),
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: DrawerDriverWidget(),
        body: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded) {
              setState(() {
                clientes = state.dataHome['clientes'] as List<Cliente>;
                productos =
                    state.dataHome['productos'] as List<ProductoAsignado>;
              });
            }
          },
          child: SafeArea(
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
              children: [nombreChofer()],
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

  Text nombreChofer() {
    final userState = context.watch<UserBloc>().state;
    if (userState is UserLoaded) {
      return Text(
        userState.usuario.nombre,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return const Text(
        'nombre del chofer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }
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
            value: '${clientes.length}',
            label: 'Clientes',
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
      children: clientes
          .map((delivery) => _buildDeliveryCard(delivery))
          .toList(),
    );
  }

  Widget _buildDeliveryCard(Cliente cliente) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent, width: 2),
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
          const SizedBox(height: 12),
          Text(
            cliente.nombreCliente,
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
                  cliente.direccionCliente,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
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
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntregaProductoScreen(
                          cliente: cliente,
                          productos: productos,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_circle_right_outlined, size: 18),
                  label: const Text('Entregar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B2A02),
                    side: const BorderSide(color: Color(0xFF6B2A02)),
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
