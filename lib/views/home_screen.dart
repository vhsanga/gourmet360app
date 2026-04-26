import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/despacho.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/viewmodels/localtion_viewmodel.dart';
import 'package:Gourmet360/views/admin/clientes_ventas_screen.dart';
import 'package:Gourmet360/views/chofer_sales_report_screen.dart';
import 'package:Gourmet360/views/entrega_producto_screen.dart';
import 'package:Gourmet360/views/templates/dialog_devolucion_productos.dart';
import 'package:Gourmet360/views/templates/dialog_registro_cliente.dart';
import 'package:Gourmet360/views/templates/drawer_driver_widget.dart';
import 'package:Gourmet360/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:Gourmet360/views/user_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';

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
  bool isConected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.status == UserStatus.loaded &&
          userProvider.usuario != null) {
        userSession = userProvider.usuario;
        final choferID = userProvider.usuario!.id;
        context.read<HomeViewModel>().getDataHome(
          userSession!.id,
          userSession!.accessToken,
        );
        context.read<LocationViewModel>().startTracking(
          onLocationChanged: (lat, lng) {
            // Esta llamada ocurre en segundo plano cada vez que el GPS se mueve
            context.read<ChoferViewModel>().registrarUbicacionChofer(
              lat,
              lng,
              int.parse(choferID),
              userSession!.accessToken,
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const DrawerDriverWidget(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Builder(
                      builder: (_) {
                        if (vm.cerrarSesion) {
                          context.read<UserProvider>().logout().then((_) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          });
                        }
                        if (vm.isLoading) {
                          return Column(
                            children: [
                              SizedBox(height: 52),
                              const Center(child: CircularProgressIndicator()),
                            ],
                          );
                        }

                        if (vm.error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 40),
                                Text(vm.error!),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<HomeViewModel>().getDataHome(
                                      userSession!.id,
                                      userSession!.accessToken,
                                    );
                                  },
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (vm.productos.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 82),
                                Text(
                                  'Todavia no hay productos asignados para hoy',
                                ),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    userSession = userProvider.usuario;
                                    context.read<HomeViewModel>().getDataHome(
                                      userSession!.id,
                                      userSession!.accessToken,
                                    );
                                  },

                                  child: const Text('Actualizar'),
                                ),
                              ],
                            ),
                          );
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
                          context.read<UserProvider>().setDespacho(
                            vm.despacho!.id,
                          );
                          despacho = vm.despacho;
                        }
                        if (locationVm.currentPosition != null) {
                          isConected = true;
                        }

                        return Column(
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        color: AppThemeData.identityColor,
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
          Icon(isConected ? Icons.wifi : Icons.wifi_off, color: Colors.white),
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
          color: AppThemeData.primaryColor,
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
            icon: Icons.attach_money_outlined,
            value: '${despacho?.totalVentas.toStringAsFixed(2) ?? '0.00'}',
            label: 'Efectivo',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientesVentasScreen()),
              );
            },
            child: _buildStatCard(
              icon: Icons.pending_outlined,
              value: '${completedToday}/${clientes.length}',
              label: 'Clientes',
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChoferSalesReportScreen(),
                ),
              );
            },
            child: _buildStatCard(
              icon: Icons.bakery_dining_rounded,
              value: despacho?.asignado.toString() ?? '0',
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
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B2A02),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppThemeData.primaryColor.withOpacity(0.7),
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
    print(userSession);
    if (userSession == null) {
      final userProvider = context.read<UserProvider>();
      userSession = userProvider.usuario;
    }
    showDialog(
      context: context,
      builder: (context) => DialogoRegistroCliente(
        idChofer: int.parse(userSession!.id),
        userSession: userSession!,
      ),
    );
  }

  void _mostrarDialogoDevolucion(BuildContext context, Cliente cliente) {
    if (userSession == null) {
      final userProvider = context.read<UserProvider>();
      userSession = userProvider.usuario;
    }
    showDialog(
      context: context,
      builder: (context) => DialogoDevolucionProductos(
        cliente: cliente,
        userSession: userSession!,
        despacho: despacho!,
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
              Row(
                children: [
                  Text(
                    cliente.nombreCliente,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B2A02),
                    ),
                  ),
                ],
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
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogoDevolucion(context, cliente);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeData.primaryColor,
                    side: const BorderSide(color: Color(0xFF6B2A02)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.compare_arrows, size: 18),
                      SizedBox(width: 4),
                      Text('Cambios'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EntregaProductoScreen(cliente: cliente),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeData.primaryColor,
                    side: const BorderSide(color: Color(0xFF6B2A02)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite, size: 18),
                      SizedBox(width: 4),
                      Text('Cortesia'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EntregaProductoScreen(cliente: cliente),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeData.primaryColor,
                    side: const BorderSide(color: Color(0xFF6B2A02)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_circle_right_outlined, size: 18),
                      SizedBox(width: 4),
                      Text('Entregar'),
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
