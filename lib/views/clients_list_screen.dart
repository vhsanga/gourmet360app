import 'package:flutter/material.dart';

class Client {
  final String id;
  final String clientName;
  final String businessName;
  final String address;
  final double amountCollectedToday;
  final double amountPending;

  Client({
    required this.id,
    required this.clientName,
    required this.businessName,
    required this.address,
    required this.amountCollectedToday,
    required this.amountPending,
  });

  double get totalDebt => amountPending;
  bool get hasPendingPayment => amountPending > 0;
  bool get hasCollectionToday => amountCollectedToday > 0;
}

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({Key? key}) : super(key: key);

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final List<Client> clients = [
    Client(
      id: '001',
      clientName: 'María González',
      businessName: 'Panadería El Sol',
      address: 'Av. Amazonas N34-451',
      amountCollectedToday: 145.50,
      amountPending: 320.00,
    ),
    Client(
      id: '002',
      clientName: 'Carlos Pérez',
      businessName: 'Supermercado La Esquina',
      address: 'Calle García Moreno 234',
      amountCollectedToday: 280.00,
      amountPending: 0.00,
    ),
    Client(
      id: '003',
      clientName: 'Ana Rodríguez',
      businessName: 'Café Central',
      address: 'Av. 12 de Octubre y Wilson',
      amountCollectedToday: 95.75,
      amountPending: 156.50,
    ),
    Client(
      id: '004',
      clientName: 'Luis Martínez',
      businessName: 'Tienda Don Lucho',
      address: 'Av. 6 de Diciembre N35-120',
      amountCollectedToday: 0.00,
      amountPending: 485.00,
    ),
    Client(
      id: '005',
      clientName: 'Patricia Sánchez',
      businessName: 'Minimarket Express',
      address: 'Calle Mariscal Foch 456',
      amountCollectedToday: 210.00,
      amountPending: 125.00,
    ),
  ];

  String searchQuery = '';
  String selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final filteredClients = _getFilteredClients();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            _buildSummaryCards(),
            Expanded(
              child: filteredClients.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        return _buildClientCard(filteredClients[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Client> _getFilteredClients() {
    List<Client> filtered = clients;

    // Filtrar por búsqueda
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((client) {
        return client.clientName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            client.businessName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Filtrar por categoría
    if (selectedFilter == 'Con Cobros') {
      filtered = filtered.where((client) => client.hasCollectionToday).toList();
    } else if (selectedFilter == 'Por Cobrar') {
      filtered = filtered.where((client) => client.hasPendingPayment).toList();
    }

    return filtered;
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
                  'Mis Clientes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${clients.length} clientes registrados',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFFF5E2C8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: TextStyle(),
        decoration: InputDecoration(
          hintText: 'Buscar cliente o negocio...',
          hintStyle: TextStyle(color: Colors.grey),
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
      child: Row(
        children: [
          _buildFilterChip('Todos', Icons.people),
          const SizedBox(width: 8),
          _buildFilterChip('Con Cobros', Icons.attach_money),
          const SizedBox(width: 8),
          _buildFilterChip('Por Cobrar', Icons.pending_actions),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;
    return Expanded(
      child: FilterChip(
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onSelected: (value) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: const Color(0xFFF5E2C8),
        selectedColor: const Color(0xFF6B2A02),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6B2A02),
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCards() {
    double totalCollected = clients.fold(
      0,
      (sum, client) => sum + client.amountCollectedToday,
    );
    double totalPending = clients.fold(
      0,
      (sum, client) => sum + client.amountPending,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Cobrado Hoy',
              '\$${totalCollected.toStringAsFixed(2)}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Por Cobrar',
              '\$${totalPending.toStringAsFixed(2)}',
              Icons.pending,
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B2A02),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildClientCard(Client client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: client.hasPendingPayment
              ? Colors.orange.shade200
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navegar a detalles del cliente
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                      child: Center(
                        child: Text(
                          client.clientName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B2A02),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.businessName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B2A02),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            client.clientName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (client.hasPendingPayment)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pendiente',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        client.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E2C8).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Cobrado Hoy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${client.amountCollectedToday.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pending_actions,
                                  size: 16,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Por Cobrar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${client.amountPending.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No se encontraron clientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra búsqueda',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
