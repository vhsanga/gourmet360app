import 'package:Gourmet360/presentation/admin/despacho_screen.dart';
import 'package:Gourmet360/presentation/admin/sales_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Driver {
  final String id;
  final String nombre;
  final String celular;
  final String rol;
  final String pin;
  final String placa;
  final String marca;
  final String modelo;
  final int capacidad;
  final bool isActive;

  Driver({
    required this.id,
    required this.nombre,
    required this.celular,
    required this.rol,
    required this.pin,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.capacidad,
    this.isActive = true,
  });
}

class DriversListScreen extends StatefulWidget {
  const DriversListScreen({Key? key}) : super(key: key);

  @override
  State<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends State<DriversListScreen> {
  final List<Driver> drivers = [
    Driver(
      id: '1',
      nombre: 'Jacobo Urquizo',
      celular: '0991234567',
      rol: 'chofer',
      pin: '123456',
      placa: 'PBX-1234',
      marca: 'Chevrolet',
      modelo: 'NPR 2020',
      capacidad: 3000,
      isActive: true,
    ),
    Driver(
      id: '2',
      nombre: 'Ancres Cepeda',
      celular: '0369654100',
      rol: 'chofer',
      pin: '123456',
      placa: 'HBC-5678',
      marca: 'JAC',
      modelo: 'Camion 2020',
      capacidad: 3000,
      isActive: true,
    ),
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDrivers = _getFilteredDrivers();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: filteredDrivers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDrivers.length,
                      itemBuilder: (context, index) {
                        return _buildDriverCard(filteredDrivers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDriverDialog(context),
        backgroundColor: const Color(0xFF6B2A02),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nuevo Conductor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  List<Driver> _getFilteredDrivers() {
    if (searchQuery.isEmpty) return drivers;
    return drivers.where((driver) {
      return driver.nombre.toLowerCase().contains(searchQuery.toLowerCase()) ||
          driver.placa.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
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
                  'Conductores',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${drivers.length} conductores registrados',
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
            icon: const Icon(Icons.filter_list, color: Colors.white, size: 28),
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
          hintText: 'Buscar por nombre o placa...',
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

  Widget _buildStatsRow() {
    final activeDrivers = drivers.where((d) => d.isActive).length;
    final inactiveDrivers = drivers.length - activeDrivers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Activos',
              activeDrivers.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Inactivos',
              inactiveDrivers.toString(),
              Icons.cancel,
              Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B2A02),
                ),
              ),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuDriverCard() {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, color: const Color(0xFF6B2A02)),
      color: Colors.white,
      onSelected: (value) {
        if (value == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesReportScreen()),
          );
        } else if (value == 2) {
          // Abrir Reportes
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DespachoScreen()),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: const [
              Icon(Icons.monetization_on, color: Color(0xFF6B2A02)),
              SizedBox(width: 10),
              Text("Reporte de ventas"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: const [
              Icon(Icons.local_shipping_outlined, color: Color(0xFF6B2A02)),
              SizedBox(width: 10),
              Text("Asignar Despacho"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
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
                          driver.nombre[0].toUpperCase(),
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
                            driver.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B2A02),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                driver.celular,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildMenuDriverCard(),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B2A02),
                        const Color(0xFF6B2A02).withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_rounded,
                            color: Color(0xFFF5E2C8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vehículo Asignado',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFF5E2C8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            driver.placa,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${driver.capacidad} kg',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${driver.marca} ${driver.modelo}',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFFF5E2C8),
                              ),
                            ),
                          ),
                        ],
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
            'No se encontraron conductores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddDriverDialog());
  }
}

class AddDriverDialog extends StatefulWidget {
  const AddDriverDialog({Key? key}) : super(key: key);

  @override
  State<AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<AddDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _celularController = TextEditingController();
  final _pinController = TextEditingController();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _capacidadController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nombreController.dispose();
    _celularController.dispose();
    _pinController.dispose();
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simular guardado
      await Future.delayed(const Duration(seconds: 2));

      // Aquí iría la lógica para guardar en el backend
      final driverData = {
        "placa": _placaController.text,
        "marca": _marcaController.text,
        "modelo": _modeloController.text,
        "capacidad": int.parse(_capacidadController.text),
        "chofer": {
          "nombre": _nombreController.text,
          "pin": _pinController.text,
          "rol": "chofer",
          "celular": _celularController.text,
        },
      };

      print(driverData); // Para debug

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Conductor registrado exitosamente!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            _buildDialogHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: 24),
                      if (_currentStep == 0) ...[
                        _buildSectionTitle('Información del Conductor'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nombreController,
                          label: 'Nombre Completo',
                          icon: Icons.person_outline,
                          hint: 'Ej: Juan Pérez',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _celularController,
                          label: 'Celular',
                          icon: Icons.phone,
                          hint: 'Ej: 0999999999',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el celular';
                            }
                            if (value.length != 10) {
                              return 'El celular debe tener 10 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _pinController,
                          label: 'PIN de Seguridad',
                          icon: Icons.lock_outline,
                          hint: 'Ej: 1234',
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el PIN';
                            }
                            if (value.length < 4) {
                              return 'El PIN debe tener al menos 4 dígitos';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        _buildSectionTitle('Información del Vehículo'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _placaController,
                          label: 'Placa',
                          icon: Icons.badge,
                          hint: 'Ej: PBC-5678',
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la placa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _marcaController,
                          label: 'Marca',
                          icon: Icons.directions_car,
                          hint: 'Ej: Hyundai',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la marca';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _modeloController,
                          label: 'Modelo',
                          icon: Icons.local_shipping,
                          hint: 'Ej: HD65',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el modelo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _capacidadController,
                          label: 'Capacidad (kg)',
                          icon: Icons.scale,
                          hint: 'Ej: 3500',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la capacidad';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildDialogActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF6B2A02),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E2C8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFF6B2A02),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Registrar Nuevo Conductor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, 'Conductor'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep > 0
                ? const Color(0xFF6B2A02)
                : const Color(0xFFF5E2C8),
          ),
        ),
        _buildStepCircle(1, 'Vehículo'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? const Color(0xFF6B2A02)
                : const Color(0xFFF5E2C8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF6B2A02),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6B2A02) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6B2A02),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B2A02),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: TextStyle(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFF6B2A02), size: 20),
            filled: true,
            fillColor: const Color(0xFFFFFCF5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFF5E2C8), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF6B2A02), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E2C8).withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() => _currentStep--);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B2A02),
                  side: const BorderSide(color: Color(0xFF6B2A02), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Atrás',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentStep == 0) {
                        if (_nombreController.text.isNotEmpty &&
                            _celularController.text.isNotEmpty &&
                            _pinController.text.isNotEmpty) {
                          setState(() => _currentStep++);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Por favor completa todos los campos',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.orange.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      } else {
                        _handleSave();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B2A02),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 0 ? 'Siguiente' : 'Guardar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
