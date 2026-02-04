import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  List<ClienteVentas> _getFilteredClientes() {
    if (_searchQuery.isEmpty) return clientes;
    var _clientes = clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    _clientes.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'ventaContadoHoy':
          comparison = a.ventaContadoHoy.compareTo(b.ventaContadoHoy);
          break;
        case 'dedudaAcumulada':
          comparison = a.dedudaAcumulada.compareTo(b.dedudaAcumulada);
          break;
        default: // nombre
          comparison = a.nombre.compareTo(b.nombre);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return _clientes;
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
      final userProvider = context.read<UserProvider>();

      if (userProvider.status == UserStatus.loaded &&
          userProvider.usuario != null) {
        userSession = userProvider.usuario;

        context.read<AdminViewModel>().getResumenVentasClientesForAdminEndpoint(
          userSession!.accessToken,
        );
      } else {
        print("No hay sesión de usuario activa.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Clientes y Ventas',
          style: TextStyle(
            color: Color(0xFF1a1a1a),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }

          if (vm.clientesVentas.isEmpty) {
            print("Lista de clientes VACIA desde VM.");
            return const Center(child: Text('No hay clientes registrados.'));
          }

          if (vm.clientesVentas.isNotEmpty) {
            print("Actualizando lista de clientes desde VM...");
            clientes = vm.clientesVentas;
            _clientesFiltrados.clear();
            _clientesFiltrados = _getFilteredClientes();
            return SafeArea(
              child: Column(
                children: [
                  // Barra de búsqueda y estadísticas
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Buscador
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar cliente...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF6366f1),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

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
          return const Center(
            child: Text('No se pudo cargar la lista de clientes.'),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    required bool isWide,
  }) {
    return Container(
      width: isWide ? 180 : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
          headingRowHeight: 56,
          dataRowHeight: 64,
          columnSpacing: 40,
          horizontalMargin: 24,
          columns: [
            DataColumn(label: _buildColumnHeader('Cliente', 'nombre')),
            DataColumn(
              label: _buildColumnHeader('Venta Contado Hoy', 'ventaContadoHoy'),
              numeric: true,
            ),
            DataColumn(
              label: _buildColumnHeader('Deuda Acumulada', 'dedudaAcumulada'),
              numeric: true,
            ),
          ],
          rows: _clientesFiltrados.map((cliente) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cliente.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  _buildMoneyChip(
                    cliente.ventaContadoHoy,
                    const Color(0xFF10b981),
                  ),
                ),
                DataCell(
                  _buildMoneyChip(
                    cliente.dedudaAcumulada,
                    cliente.dedudaAcumulada > 0
                        ? const Color(0xFFef4444)
                        : const Color(0xFF6b7280),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clientesFiltrados.length,
      itemBuilder: (context, index) {
        final cliente = _clientesFiltrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          cliente.nombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cliente.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Venta Contado',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${cliente.ventaContadoHoy.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF10b981),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Deuda Acumulada',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${cliente.dedudaAcumulada.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cliente.dedudaAcumulada > 0
                                ? const Color(0xFFef4444)
                                : const Color(0xFF6b7280),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isActive ? const Color(0xFF6366f1) : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive
                ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 18,
            color: isActive ? const Color(0xFF6366f1) : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyChip(double amount, Color color) {
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
}
