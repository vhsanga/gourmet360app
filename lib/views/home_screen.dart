import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/services/connectivity_service.dart';
import 'package:Gourmet360/services/sync_queue_service.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/despacho.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/views/admin/clientes_ventas_screen.dart';
import 'package:Gourmet360/views/chofer_sales_report_screen.dart';
import 'package:Gourmet360/views/client_history_sales_screen.dart';
import 'package:Gourmet360/views/entrega_producto_screen.dart';
import 'package:Gourmet360/views/templates/dialog_cortesia.dart';
import 'package:Gourmet360/views/templates/dialog_devolucion_productos.dart';
import 'package:Gourmet360/views/templates/dialog_editar_cliente.dart';
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
  bool _sortByName = false;
  bool _showOtherChoferes = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String choferID = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.status == UserStatus.loaded &&
          userProvider.usuario != null) {
        userSession = userProvider.usuario;
        choferID = userProvider.usuario!.id;
        context.read<HomeViewModel>().getDataHome(
          userSession!.id,
          userSession!.accessToken,
        );
        /*context.read<LocationViewModel>().startTracking(
          onLocationChanged: (lat, lng) {
            // Esta llamada ocurre en segundo plano cada vez que el GPS se mueve
            context.read<ChoferViewModel>().registrarUbicacionChofer(
              lat,
              lng,
              int.parse(choferID),
              userSession!.accessToken,
            );
          },
        );*/
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final userProvider = context.read<UserProvider>();
    final connectivity = context.watch<ConnectivityService>();
    final syncQueue = context.watch<SyncQueueService>();
    isConected = connectivity.isOnline;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const DrawerDriverWidget(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(syncQueue),
            if (!isConected)
              Container(
                width: double.infinity,
                color: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sin conexión — mostrando datos guardados',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsCards(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(),
                            const SizedBox(height: 8),
                            _buildSearchField(),
                            const SizedBox(height: 12),
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

  Widget _buildHeader(SyncQueueService syncQueue) {
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (syncQueue.isSyncing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  isConected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                ),
              if (syncQueue.pendingCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${syncQueue.pendingCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
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
                  builder: (context) =>
                      ChoferSalesReportScreen(idDespacho: despacho?.id),
                ),
              );
            },
            child: _buildStatCard(
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) =>
          setState(() => _searchQuery = value.trim().toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Buscar cliente...',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    final myCount =
        clientes.where((c) => c.idChofer.toString() == choferID).length;
    final othersCount =
        clientes.where((c) => c.idChofer.toString() != choferID).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              _showOtherChoferes
                  ? 'Clientes de otros ($othersCount)'
                  : 'Mis Clientes ($myCount)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B2A02),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: _showOtherChoferes
                  ? 'Ver mis clientes'
                  : 'Ver otros choferes',
              onPressed: () =>
                  setState(() => _showOtherChoferes = !_showOtherChoferes),
              icon: Icon(
                _showOtherChoferes
                    ? Icons.people_alt
                    : Icons.people_alt_outlined,
                size: 28,
                color: _showOtherChoferes ? Colors.orange : Colors.grey,
              ),
            ),
            IconButton(
              tooltip: _sortByName ? 'Quitar orden A-Z' : 'Ordenar A-Z',
              onPressed: () => setState(() => _sortByName = !_sortByName),
              icon: Icon(
                Icons.sort_by_alpha_sharp,
                size: 28,
                color: _sortByName ? AppThemeData.primaryColor : Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {
                _mostrarDialogoRegistro(context);
              },
              icon: const Icon(Icons.add_circle_outline, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryList() {
    var list = _sortByName
        ? ([...clientes]
            ..sort((a, b) => a.nombreCliente.compareTo(b.nombreCliente)))
        : clientes;
    list = list
        .where(
          (c) => _showOtherChoferes
              ? c.idChofer.toString() != choferID
              : c.idChofer.toString() == choferID,
        )
        .toList();
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((c) => c.nombreCliente.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Column(
        key: ValueKey('$_sortByName-$_searchQuery-$_showOtherChoferes'),
        children: list.map((delivery) => _buildDeliveryCard(delivery)).toList(),
      ),
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

  void _mostrarDialogoCortesia(BuildContext context, Cliente cliente) {
    if (userSession == null) {
      final userProvider = context.read<UserProvider>();
      userSession = userProvider.usuario;
    }
    showDialog(
      context: context,
      builder: (context) => DialogoCortesia(
        cliente: cliente,
        userSession: userSession!,
        despacho: despacho!,
      ),
    );
  }

  Widget _buildDeliveryCard(Cliente cliente) {
    ClienteVentas clienteVentas = ClienteVentas(
      id: cliente.idCliente,
      nombre: cliente.nombreCliente,
      contacto: cliente.telefonoCliente,
      direccion: cliente.direccionCliente,
      ventaContadoHoy: 0.0,
      dedudaAcumulada: 0.0,
      especial: cliente.especial,
    );
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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClientHistorySalesScreen(cliente: clienteVentas),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        cliente.nombreCliente,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B2A02),
                        ),
                      ),
                    ),
                    if (cliente.entregado > 0)
                      Icon(Icons.verified, color: Colors.blue, size: 22),
                  ],
                ),
                if (cliente.diasDeuda == 0)
                  Icon(Icons.circle, color: Colors.green, size: 22),
                if (cliente.diasDeuda == 1)
                  Icon(Icons.circle, color: Colors.orange, size: 22),
                if (cliente.diasDeuda > 1)
                  Icon(Icons.circle, color: Colors.red, size: 22),
              ],
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
                    _mostrarDialogoCortesia(context, cliente);
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
