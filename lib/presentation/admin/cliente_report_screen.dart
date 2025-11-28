import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientData {
  final String id;
  final String name;
  final String businessName;
  final double todaySales;
  final double accumulatedDebt;
  final ClientType clientType;

  ClientData({
    required this.id,
    required this.name,
    required this.businessName,
    required this.todaySales,
    required this.accumulatedDebt,
    required this.clientType,
  });
}

enum ClientType { normal, especial }

class ClientsReportScreen extends StatefulWidget {
  const ClientsReportScreen({Key? key}) : super(key: key);

  @override
  State<ClientsReportScreen> createState() => _ClientsReportScreenState();
}

class _ClientsReportScreenState extends State<ClientsReportScreen> {
  final List<ClientData> clients = [
    ClientData(
      id: '1',
      name: 'María González',
      businessName: 'Panadería El Sol',
      todaySales: 145.50,
      accumulatedDebt: 320.00,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: '2',
      name: 'Carlos Pérez',
      businessName: 'Supermercado La Esquina',
      todaySales: 280.00,
      accumulatedDebt: 0.00,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: '3',
      name: 'Ana Rodríguez',
      businessName: 'Café Central',
      todaySales: 95.75,
      accumulatedDebt: 156.50,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: '4',
      name: 'Luis Martínez',
      businessName: 'Tienda Don Lucho',
      todaySales: 0.00,
      accumulatedDebt: 485.00,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: '5',
      name: 'Patricia Sánchez',
      businessName: 'Minimarket Express',
      todaySales: 210.00,
      accumulatedDebt: 125.00,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: '6',
      name: 'Roberto Gómez',
      businessName: 'Bodega Mi Barrio',
      todaySales: 87.30,
      accumulatedDebt: 0.00,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: '7',
      name: 'Elena Castro',
      businessName: 'Cafetería La Luna',
      todaySales: 165.80,
      accumulatedDebt: 230.00,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: '8',
      name: 'Diego Vargas',
      businessName: 'Panadería San José',
      todaySales: 320.50,
      accumulatedDebt: 0.00,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: "9",
      name: "Carlos Mendoza",
      businessName: "Panadería San José",
      todaySales: 485.75,
      accumulatedDebt: 0.0,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: "10",
      name: "Ana López",
      businessName: "Restaurante El Sol",
      todaySales: 892.30,
      accumulatedDebt: 156.80,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: "11",
      name: "Miguel Torres",
      businessName: "Tienda Central",
      todaySales: 234.15,
      accumulatedDebt: 89.45,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: "12",
      name: "Laura García",
      businessName: "Supermercado Premium",
      todaySales: 1123.90,
      accumulatedDebt: 0.0,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: "13",
      name: "Diego Vargas",
      businessName: "Farmacia La Luna",
      todaySales: 678.25,
      accumulatedDebt: 234.10,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: "14",
      name: "Sofia Rodríguez",
      businessName: "Librería Del Norte",
      todaySales: 345.60,
      accumulatedDebt: 67.35,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: "15",
      name: "Jorge Hernández",
      businessName: "Ropa Express",
      todaySales: 756.80,
      accumulatedDebt: 0.0,
      clientType: ClientType.especial,
    ),
    ClientData(
      id: "16",
      name: "Elena Castro",
      businessName: "Electrónica Moderna",
      todaySales: 1892.45,
      accumulatedDebt: 456.90,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: "17",
      name: "Pedro Silva",
      businessName: "Juguetería Tradicional",
      todaySales: 278.95,
      accumulatedDebt: 123.25,
      clientType: ClientType.normal,
    ),
    ClientData(
      id: "18",
      name: "Carmen Morales",
      businessName: "Florería Del Sur",
      todaySales: 412.70,
      accumulatedDebt: 0.0,
      clientType: ClientType.especial,
    ),
  ];

  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String _filterType = 'Todos';
  String _searchQuery = '';

  List<ClientData> get filteredClients {
    List<ClientData> filtered = clients;

    // Filtrar por tipo
    if (_filterType == 'Normal') {
      filtered = filtered
          .where((c) => c.clientType == ClientType.normal)
          .toList();
    } else if (_filterType == 'Especial') {
      filtered = filtered
          .where((c) => c.clientType == ClientType.especial)
          .toList();
    } else if (_filterType == 'Con Deuda') {
      filtered = filtered.where((c) => c.accumulatedDebt > 0).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.businessName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  double get totalSalesToday {
    return clients.fold(0, (sum, client) => sum + client.todaySales);
  }

  double get totalDebt {
    return clients.fold(0, (sum, client) => sum + client.accumulatedDebt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              _buildSummaryCards(),
              Expanded(child: _buildDataTable()),
            ],
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reporte de Clientes',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${clients.length} clientes registrados',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: const Color(0xFFF5E2C8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: GoogleFonts.montserrat(),
        decoration: InputDecoration(
          hintText: 'Buscar cliente...',
          hintStyle: GoogleFonts.montserrat(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B2A02)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFFF5E2C8), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF6B2A02), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Todos', Icons.people),
          const SizedBox(width: 8),
          _buildFilterChip('Normal', Icons.person),
          const SizedBox(width: 8),
          _buildFilterChip('Especial', Icons.star),
          const SizedBox(width: 8),
          _buildFilterChip('Con Deuda', Icons.warning_amber),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _filterType == label;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF6B2A02),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      onSelected: (value) {
        setState(() {
          _filterType = label;
        });
      },
      backgroundColor: const Color(0xFFF5E2C8),
      selectedColor: const Color(0xFF6B2A02),
      labelStyle: GoogleFonts.montserrat(
        color: isSelected ? Colors.white : const Color(0xFF6B2A02),
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Ventas Hoy',
              '\$${totalSalesToday.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Deuda Total',
              '\$${totalDebt.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B2A02),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    final filtered = filteredClients;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16, // <<< MUCHO MÁS PEQUEÑO
            horizontalMargin: 8, // <<< REDUCIDO
            dataRowMinHeight: 32, // <<< MÁS COMPACTO
            dataRowMaxHeight: 48, // <<< MÁS COMPACTO
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            headingRowColor: MaterialStateProperty.all(const Color(0xFF6B2A02)),
            headingTextStyle: GoogleFonts.montserrat(
              fontSize: 11, // <<< REDUCIDO
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            dataTextStyle: GoogleFonts.montserrat(
              fontSize: 11, // <<< REDUCIDO
              color: const Color(0xFF6B2A02),
            ),

            columns: [
              DataColumn(
                label: const Text('Cliente'),
                onSort: (i, a) => _sortBy(filtered, i, a, (e) => e.name),
              ),
              DataColumn(
                label: const Text('Hoy'),
                numeric: true,
                onSort: (i, a) => _sortBy(filtered, i, a, (e) => e.todaySales),
              ),
              DataColumn(
                label: const Text('Deuda'),
                numeric: true,
                onSort: (i, a) =>
                    _sortBy(filtered, i, a, (e) => e.accumulatedDebt),
              ),
              DataColumn(
                label: const Text('Tipo'),
                onSort: (i, a) =>
                    _sortBy(filtered, i, a, (e) => e.clientType.name),
              ),
            ],

            rows: filtered.map((client) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 140, // <<< ANTES 200 – AHORA COMPACTO
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.businessName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 12, // <<< REDUCIDO
                              color: const Color(0xFF6B2A02),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            client.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 10, // <<< REDUCIDO
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ), // <<< REDUCIDO
                      decoration: BoxDecoration(
                        color: client.todaySales > 0
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${client.todaySales.toStringAsFixed(1)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: client.todaySales > 0
                              ? Colors.green.shade800
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ), // <<< REDUCIDO
                      decoration: BoxDecoration(
                        color: client.accumulatedDebt > 0
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${client.accumulatedDebt.toStringAsFixed(1)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: client.accumulatedDebt > 0
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),

                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ), // <<< REDUCIDO
                      decoration: BoxDecoration(
                        color: client.clientType == ClientType.especial
                            ? const Color(0xFF6B2A02)
                            : const Color(0xFFF5E2C8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            client.clientType == ClientType.especial
                                ? Icons.star
                                : Icons.person,
                            size: 12, // <<< REDUCIDO
                            color: client.clientType == ClientType.especial
                                ? Colors.white
                                : const Color(0xFF6B2A02),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            client.clientType == ClientType.especial
                                ? 'Esp.'
                                : 'Norm.',
                            style: GoogleFonts.montserrat(
                              fontSize: 10, // <<< REDUCIDO
                              fontWeight: FontWeight.bold,
                              color: client.clientType == ClientType.especial
                                  ? Colors.white
                                  : const Color(0xFF6B2A02),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _sortBy(List list, int index, bool asc, Function key) {
    setState(() {
      _sortColumnIndex = index;
      _sortAscending = asc;
      list.sort(
        (a, b) => asc
            ? Comparable.compare(key(a), key(b))
            : Comparable.compare(key(b), key(a)),
      );
    });
  }
}
