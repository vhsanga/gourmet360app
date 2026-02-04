import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/despacho.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/views/entrega_producto_screen.dart';
import 'package:Gourmet360/views/templates/dialog_registro_cliente.dart';
import 'package:Gourmet360/views/templates/drawer_driver_widget.dart';
import 'package:flutter/material.dart';
import 'package:Gourmet360/views/productos_inventory_screen.dart';
import 'package:Gourmet360/views/user_profile_screen.dart';
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
  int completedToday = 0;
  Usuario? userSession;
  Despacho? despacho;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.status == UserStatus.loaded &&
          userProvider.usuario != null) {
        print("Cargando lista de conductores para admin...");

        userSession = userProvider.usuario;
        context.read<HomeViewModel>().getDataHome(
          userSession!.id,
          userSession!.accessToken,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const DrawerDriverWidget(),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.productos.isEmpty) {
            return const Center(child: Text('No hay productos chofer'));
          }
          if (vm.productos.isNotEmpty) {
            productos = vm.productos;
          }
          if (vm.clientes.isNotEmpty) {
            clientes = vm.clientes;
            completedToday = clientes
                .where((cliente) => cliente.entregado > 0)
                .toList()
                .length;
          }
          if (vm.despacho != null) {
            context.read<UserProvider>().setDespacho(vm.despacho!.id);
            despacho = vm.despacho;
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsCards(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Mis Clientes'),
                            const SizedBox(height: 16),
                            _buildDeliveryList(),
                            const SizedBox(height: 16),
                            if (clientes.isEmpty) _buildRegisterButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<HomeViewModel>().getDataHome(
      userSession!.id,
      userSession!.accessToken,
    ); // ← TU método (API + estados)
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
    final userState = context.watch<UserProvider>();
    if (userState.status == UserStatus.loaded) {
      return Text(
        userState.usuario?.nombre ?? "",
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
            label: 'entregados',
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
              value: despacho?.restante.toString() ?? '0',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B2A02),
          ),
        ),
        IconButton(
          onPressed: () {
            _mostrarDialogoRegistro(context);
          },
          icon: const Icon(Icons.add_circle_outline, size: 32),
        ),
      ],
    );
  }

  Widget _buildDeliveryList() {
    return Column(
      children: clientes
          .map((delivery) => _buildDeliveryCard(delivery))
          .toList(),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _mostrarDialogoRegistro(context),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Cliente'),
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoRegistro(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DialogoRegistroCliente(
        idChofer: int.parse(userSession!.id),
        userSession: userSession!,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cliente.nombreCliente,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B2A02),
                ),
              ),
              if (cliente.entregado > 0)
                Icon(Icons.check_circle, color: Colors.green),
            ],
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
