import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/despacho.dart';
import 'package:Gourmet360/models/producto.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/viewmodels/producto_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DialogoDevolucionProductos extends StatefulWidget {
  final Cliente cliente;
  final Despacho despacho;
  final Usuario userSession;
  final Function(String idCliente, int cantidad)? onGuardar;

  const DialogoDevolucionProductos({
    Key? key,
    required this.cliente,
    required this.userSession,
    required this.despacho,
    this.onGuardar,
  }) : super(key: key);

  @override
  State<DialogoDevolucionProductos> createState() =>
      _DialogoDevolucionProductosState();
}

class _DialogoDevolucionProductosState
    extends State<DialogoDevolucionProductos> {
  final _formKey = GlobalKey<FormState>();
  List<ProductoAsignado> _productosAsignados = [];
  final Map<String, TextEditingController> _controllers = {};
  Usuario? userSession;
  final List<Map<String, dynamic>> _itemsAsignados = [];

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
      context.read<ProductoViewModel>().listarProductosCliente(
        int.parse(userSession!.id),
        int.parse(widget.cliente.idCliente),
        userSession!.accessToken,
      );
      for (var product in _productosAsignados) {
        _controllers[product.productoId.toString()] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int get totalProducts {
    return _productosAsignados.fold(
      0,
      (sum, product) => sum + product.cantidad,
    );
  }

  void _guardarDevolucion() async {
    if (_formKey.currentState!.validate()) {
      final choferVM = context.read<ChoferViewModel>();
      final detalles = _productosAsignados
          .where((p) => p.cantidad > 0)
          .map((p) => {'productoId': int.parse(p.productoId), 'cantidad': p.cantidad})
          .toList();
      Map<String, dynamic> data = {
        "cantidad": totalProducts,
        "clienteId": int.parse(widget.cliente.idCliente),
        "choferId": int.parse(widget.userSession.id),
        "despachoId": widget.despacho.id,
        "detalles": detalles,
      };

      DialogsWidget.showLoading(message: 'Procesando...');
      final navigator = Navigator.of(context, rootNavigator: true);
      final success = await choferVM.registrarDevolucionCliente(
        data,
        widget.userSession.accessToken ?? '',
      );
      if (!mounted) return;
      navigator.pop();
      if (success) {
        DialogsWidget.showSuccess(
          title: 'Muy bien',
          message: choferVM.msj ?? 'Cliente registrado correctfamente',
          onClose: () {
            Navigator.pop(context);
          },
        );
        return;
      } else {
        DialogsWidget.showError(
          title: 'Atención',
          message: choferVM.msj ?? 'Error desconocido',
        );
        return;
      }
    }
  }

  void _cancelar() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFef4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_return,
                        color: Color(0xFFef4444),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Cambios',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _cancelar,
                      icon: const Icon(Icons.close),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Información del cliente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Cliente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.cliente.nombreCliente,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      if (widget.cliente.direccionCliente.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.cliente.direccionCliente,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Builder(
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
                    if (vm.productosAsignados.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Text('No hay productos para cambios'),
                            SizedBox(height: 4),
                          ],
                        ),
                      );
                    }
                    if (vm.productosAsignados.isNotEmpty) {
                      _productosAsignados = vm.productosAsignados;
                    }
                    return _buildProductsList();
                  },
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      "Total productos: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      totalProducts.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppThemeData.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _cancelar,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _guardarDevolucion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFef4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Column(
      children: _productosAsignados
          .map((product) => _buildProductCard(product))
          .toList(),
    );
  }

  Widget _buildProductCard(ProductoAsignado product) {
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.producto,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeData.primaryColor,
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  'Stock: ${product.cantidadRestante.round()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: product.cantidadRestante == 0
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 110,
                          child: TextField(
                            enabled: product.cantidadRestante != 0,
                            controller: _controllers[product.productoId],
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

  void _updateQuantity(ProductoAsignado producto, String value) {
    final quantity = int.tryParse(value) ?? 0;
    String productId = producto.productoId;
    setState(() {
      final product = _productosAsignados.firstWhere(
        (p) => p.productoId == productId,
      );
      product.cantidad = quantity;
      _itemsAsignados.add({"producto": producto, "cantidad": quantity});
    });
  }
}
