import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:Gourmet360/views/client_history_sales_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';

class ClientesVentasScreen extends StatefulWidget {
  const ClientesVentasScreen({Key? key}) : super(key: key);

  @override
  State<ClientesVentasScreen> createState() => _ClientesVentasScreenState();
}

class _ClientesVentasScreenState extends State<ClientesVentasScreen> {
  String _searchQuery = '';
  String _sortBy = 'nombre'; // nombre, ventaContadoHoy, dedudaAcumulada
  bool _sortAscending = true;
  List<ClienteVentas> clientes = [];
  List<ClienteVentas> _clientesFiltrados = [];
  Usuario? userSession;
  DateTime? _fechaSeleccionada = DateTime.now();

  List<ClienteVentas> _getFilteredClientes() {
    if (_searchQuery.isEmpty) return clientes;
    var _clientes = clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    return _ordenarClientes(_clientes);
  }

  List<ClienteVentas> _ordenarClientes(List<ClienteVentas> lista) {
    final ordenada = List<ClienteVentas>.from(lista);
    ordenada.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'ventaContadoHoy':
          comparison = a.ventaContadoHoy.compareTo(b.ventaContadoHoy);
          break;
        case 'dedudaAcumulada':
          comparison = a.dedudaAcumulada.compareTo(b.dedudaAcumulada);
          break;
        case 'devolucionHoy':
          comparison = a.devolucionHoy.compareTo(b.devolucionHoy);
          break;
        default: // nombre
          comparison = a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      }
      return _sortAscending ? comparison : -comparison;
    });
    return ordenada;
  }

  double get _totalVentaContado {
    return _clientesFiltrados.fold(
      0,
      (sum, cliente) => sum + cliente.ventaContadoHoy,
    );
  }

  double get _totalDeudaAcumulada {
    return _clientesFiltrados.fold(
      0,
      (sum, cliente) => sum + cliente.dedudaAcumulada,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();

    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      userSession = userProvider.usuario;

      await context
          .read<AdminViewModel>()
          .getResumenVentasClientesForAdminEndpoint(
            _fechaSeleccionada != null
                ? CustomUils.formatDateToString(_fechaSeleccionada!)
                : CustomUils.fechaActual(),
            userSession!.accessToken,
            userSession!.rol,
            userSession!.id.toString(),
          );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vm = context.read<AdminViewModel>();

    if (vm.clientesVentas.isNotEmpty) {
      clientes = vm.clientesVentas;
      _clientesFiltrados = _getFilteredClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppThemeData.identityColor,
        iconTheme: IconThemeData(
          color: AppThemeData.primaryColor, //change your color here
        ),
        title: const Text(
          'Clientes y Ventas',
          style: TextStyle(
            color: AppThemeData.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                children: [
                  Text(vm.error!),
                  ElevatedButton(
                    onPressed: () {
                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (vm.clientesVentas.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text('No hay clientes registrados.'),
                  ElevatedButton(
                    onPressed: () {
                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (vm.clientesVentas.isNotEmpty) {
            print("Actualizando lista de clientes desde VM...");
            return SafeArea(
              child: Column(
                children: [
                  // Barra de búsqueda
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _clientesFiltrados = _getFilteredClientes();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppThemeData.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tabla
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return _buildDataTable();
                            //return _buildCardList();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              children: [
                Text('No se pudo cargar la lista de clientes.'),
                ElevatedButton(
                  onPressed: () {
                    _loadData();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con fecha y botón de calendario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CustomUils.formatearFecha(_fechaSeleccionada!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B2A02),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    color: AppThemeData.primaryColor,
                    tooltip: 'Seleccionar fecha',
                    onPressed: () => _seleccionarFecha(context),
                  ),
                ],
              ),
            ),

            // Tabla
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                headingRowHeight: 48,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 90,
                columnSpacing: 4,
                horizontalMargin: 8,
                columns: [
                  DataColumn(label: _buildColumnHeader('Cliente', 'nombre')),
                  DataColumn(
                    label: _buildColumnHeader('Venta dia', 'ventaContadoHoy'),
                    numeric: true,
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Total deuda', 'dedudaAcumulada'),
                    numeric: true,
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Devolución', 'devolucionHoy'),
                    numeric: true,
                  ),
                ],
                rows: _clientesFiltrados.map((cliente) {
                  void onRowTap() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClientHistorySalesScreen(cliente: cliente),
                      ),
                    );
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 110,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  cliente.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: onRowTap,
                      ),
                      DataCell(
                        _buildMoneyChip(
                          cliente.ventaContadoHoy,
                          const Color(0xFF10b981),
                        ),
                        onTap: onRowTap,
                      ),
                      DataCell(
                        _buildMoneyChip(
                          cliente.dedudaAcumulada,
                          cliente.dedudaAcumulada > 0
                              ? const Color(0xFFef4444)
                              : const Color(0xFF6b7280),
                        ),
                        onTap: onRowTap,
                      ),
                      DataCell(
                        _buildAccountChip(
                          cliente.devolucionHoy,
                          const Color(0xFFf59e0b),
                        ),
                        onTap: onRowTap,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B2A02),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaSeleccionada = fechaSeleccionada;
      });
      _loadData();
    }
  }

  Widget _buildColumnHeader(String title, String sortKey) {
    final isActive = _sortBy == sortKey;
    return InkWell(
      onTap: () {
        setState(() {
          if (_sortBy == sortKey) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = sortKey;
            _sortAscending = true;
          }
          _clientesFiltrados = _ordenarClientes(_clientesFiltrados);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: isActive ? AppThemeData.primaryColor : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            isActive
                ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 14,
            color: isActive ? AppThemeData.primaryColor : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyChip(double amount, Color color) {
    if (amount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '--',
          style: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$${amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAccountChip(double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: amount > 0 ? color.withOpacity(0.1) : color.withOpacity(0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        amount > 0 ? '$amount' : '--',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
