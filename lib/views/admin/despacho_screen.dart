import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/camion_asignado.dart';
import 'package:Gourmet360/models/producto.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/producto_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialog_registro_producto.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';

class DespachoScreen extends StatefulWidget {
  CamionAsignado? camionAsignado;
  DespachoScreen({Key? key, required this.camionAsignado}) : super(key: key);

  @override
  State<DespachoScreen> createState() => _DespachoScreenState();
}

class _DespachoScreenState extends State<DespachoScreen> {
  List<Producto> _productos = [];
  final Map<String, TextEditingController> _controllers = {};
  Usuario? userSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      print("Cargando lista de conductores para admin...");

      userSession = userProvider.usuario;
      context.read<ProductoViewModel>().listarProductosForAdmin(
        userSession!.accessToken,
      );
      for (var product in _productos) {
        _controllers[product.id.toString()] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    // Liberar controladores
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int get totalProducts {
    return _productos.fold(0, (sum, product) => sum + product.cantidad);
  }

  double get totalValue {
    return _productos.fold(
      0,
      (sum, product) => sum + (product.cantidad * product.precioUnitario),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    return Scaffold(
      appBar: _buildAppBar(context),
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

          if (vm.productos.isEmpty) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text('No hay productos para despacho'),
                  SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      _mostrarDialogoRegistroProducto(context);
                    },
                    child: const Text('Crear primer producto'),
                  ),
                ],
              ),
            );
          }
          if (vm.productos.isNotEmpty) {
            _productos = vm.productos;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChoferCard(),
                      SizedBox(height: 20),
                      _buildActionCreateNewProducto(),
                      SizedBox(height: 20),
                      _buildProductsList(),
                      const SizedBox(height: 60),
                      if (_itemsAsignados.isNotEmpty) _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoRegistroProducto(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DialogRegistroProducto(userSession: userSession!),
    );
  }

  Widget _buildActionCreateNewProducto() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            _mostrarDialogoRegistroProducto(context);
          },
          child: Row(
            children: [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text('Crear Nuevo Producto'),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Despachar', style: TextStyle(color: Colors.white)),
          Container(
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      'Unidades',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E2C8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        totalProducts.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppThemeData.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      'Total V',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${totalValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
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
      backgroundColor: AppThemeData.identityColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppThemeData.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProductsList() {
    return Column(
      children: _productos
          .map((product) => _buildProductCard(product))
          .toList(),
    );
  }

  Widget _buildProductCard(Producto product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.cantidad > 0
              ? AppThemeData.primaryColor
              : const Color(0xFFF5E2C8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.nombre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppThemeData.primaryColor,
                              ),
                            ),
                            if (product.cantidad > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Subtotal: ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(product.cantidad * product.precioUnitario).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          width: 120,
                          child: TextField(
                            controller: _controllers[product.id],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppThemeData.primaryColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cantidad',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: AppThemeData.backgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFFF5E2C8),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppThemeData.primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) =>
                                _updateQuantity(product, value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateQuantity(Producto producto, String value) {
    final quantity = int.tryParse(value) ?? 0;
    int productId = producto.id;
    setState(() {
      final product = _productos.firstWhere((p) => p.id == productId);
      product.cantidad = quantity;
      _itemsAsignados.add({"producto": producto, "cantidad": quantity});
    });
  }

  Producto? _productoSeleccionado;
  final TextEditingController _cantidadController = TextEditingController();

  final List<Map<String, dynamic>> _itemsAsignados = [];

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
                widget.camionAsignado!.uNombre,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.camionAsignado!.camionPlaca,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => submitGuardar(context),
                icon: const Icon(Icons.edit),
                label: Text(
                  'Guardar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primaryColor,
                  foregroundColor: AppThemeData.backgroundColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  submitGuardar(BuildContext context) async {
    final detalles = _productos
        .where((p) => p.cantidad > 0)
        .map((p) => {'producto_id': p.id, 'cantidad': p.cantidad})
        .toList();

    Map<String, dynamic> data = {
      'camion_id': widget.camionAsignado?.camionId ?? '',
      'chofer_id': widget.camionAsignado?.uId ?? '',
      'detalles': detalles,
    };

    final productoVM = context.read<ProductoViewModel>();
    DialogsWidget.showLoading(message: 'Procesando...');
    final navigator = Navigator.of(context, rootNavigator: true);
    final success = await productoVM.asignarProductos(
      data,
      userSession?.accessToken ?? '',
    );
    if (!mounted) return;
    navigator.pop();
    if (success) {
      DialogsWidget.showSuccess(
        title: 'Muy bien',
        message: productoVM.msj ?? 'Productos asignados correctamente',
        onClose: () {
          for (final p in _productos) {
            p.cantidad = 0;
          }
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
      return;
    } else {
      DialogsWidget.showError(
        title: 'Atención',
        message: productoVM.msj ?? 'Error desconocido',
      );
      return;
    }
  }
}
