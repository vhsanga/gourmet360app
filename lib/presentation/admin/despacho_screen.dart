import 'package:flutter/material.dart';

class DespachoScreen extends StatefulWidget {
  const DespachoScreen({Key? key}) : super(key: key);

  @override
  State<DespachoScreen> createState() => _DespachoScreenState();
}

class _DespachoScreenState extends State<DespachoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asignar Productos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B2A02),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de perfil

          // Contenido del perfil
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChoferCard(),
                  SizedBox(height: 20),
                  _buildFormularioAsignacion(),
                  _buildListaAsignados(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // CONTROLADORES Y VARIABLES
  // ===============================
  final List<String> _productos = [
    "Pan Francés",
    "Pan Dulce",
    "Pastel",
    "Torta",
  ];
  String? _productoSeleccionado;
  final TextEditingController _cantidadController = TextEditingController();

  final List<Map<String, dynamic>> _itemsAsignados = [];

  // ===============================
  // MÉTODO: AGREGAR PRODUCTO A LA LISTA
  // ===============================
  void _agregarProducto() {
    if (_productoSeleccionado == null || _cantidadController.text.isEmpty)
      return;

    setState(() {
      _itemsAsignados.add({
        "producto": _productoSeleccionado!,
        "cantidad": int.parse(_cantidadController.text),
      });
    });

    _cantidadController.clear();
    _productoSeleccionado = null;
  }

  // ===============================
  // WIDGET: CARD BÁSICO DEL CHOFER
  // ===============================
  Widget _buildChoferCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 40, color: Color(0xFF6B2A02)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chofer: Jacobo Urquizo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Placa: PBX-1234",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================
  // WIDGET: FORMULARIO PARA ASIGNAR PRODUCTOS
  // ===============================
  Widget _buildFormularioAsignacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Dropdown Productos
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Producto",
            border: OutlineInputBorder(),
          ),
          value: _productoSeleccionado,
          items: _productos
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _productoSeleccionado = v),
        ),

        const SizedBox(height: 12),

        // Cantidad
        TextField(
          controller: _cantidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Cantidad",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        // Botón agregar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _agregarProducto,
            icon: Icon(Icons.add),
            label: Text("Agregar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B2A02),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================
  // WIDGET: LISTA DE PRODUCTOS ASIGNADOS
  // ===============================
  Widget _buildListaAsignados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Productos Asignados",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B2A02),
          ),
        ),
        const SizedBox(height: 10),

        if (_itemsAsignados.isEmpty) Text("No hay productos asignados aún."),

        ..._itemsAsignados.map(
          (item) => Card(
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: Color(0xFF6B2A02)),
              title: Text(item["producto"]),
              subtitle: Text("Cantidad: ${item["cantidad"]}"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6B2A02),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E2C8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6B2A02), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6B2A02),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B2A02),
            const Color(0xFF6B2A02).withOpacity(0.8),
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
                      'Placa',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFF5E2C8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PBX-1234',
                      style: TextStyle(
                        fontSize: 24,
                        color: const Color(0xFFFFFCF5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marca',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5E2C8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chevrolet',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFFFFCF5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modelo',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5E2C8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NPR 2020',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFFFFCF5),
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: Text(
              'Editar Perfil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2A02),
              foregroundColor: const Color(0xFFFFFCF5),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B2A02),
              side: const BorderSide(color: Color(0xFF6B2A02), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
