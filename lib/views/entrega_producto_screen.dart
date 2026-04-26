import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/producto_asignados.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/viewmodels/producto_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';

class OrderItem {
  final ProductoAsignado product;
  final Cliente clienteOrden;
  int quantity;

  OrderItem({
    required this.product,
    required this.clienteOrden,
    required this.quantity,
  });

  double get subtotal => product.precioUnitario * quantity;
}

enum PaymentType { contado, credito }

class EntregaProductoScreen extends StatefulWidget {
  Cliente cliente;

  EntregaProductoScreen({super.key, required this.cliente});

  @override
  State<EntregaProductoScreen> createState() => _EntregaProductoScreenState();
}

class _EntregaProductoScreenState extends State<EntregaProductoScreen> {
  // Lista de productos en el pedidonp
  final List<OrderItem> orderItems = [];

  // Formulario
  ProductoAsignado? selectedProduct;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController newPricingController = TextEditingController();
  PaymentType selectedPaymentType = PaymentType.contado;
  Usuario? userSession;
  List<ProductoAsignado> productos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    newPricingController.dispose();
    super.dispose();
  }

  double get totalAmount {
    return orderItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalItems {
    return orderItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _addProduct() {
    if (selectedProduct == null) {
      _showSnackBar('Por favor selecciona un producto', isError: true);
      return;
    }

    if (quantityController.text.isEmpty) {
      _showSnackBar('Por favor ingresa la cantidad', isError: true);
      return;
    }

    final quantity = int.tryParse(quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showSnackBar('La cantidad debe ser mayor a 0', isError: true);
      return;
    }

    if (quantity > selectedProduct!.cantidadRestante) {
      _showSnackBar(
        'Stock insuficiente. Disponible: ${selectedProduct!.cantidadRestante}',
        isError: true,
      );
      return;
    }

    // Verificar si el producto ya está en el pedido
    final existingIndex = orderItems.indexWhere(
      (item) => item.product.productoId == selectedProduct!.productoId,
    );

    setState(() {
      if (existingIndex != -1) {
        orderItems[existingIndex].quantity += quantity;
      } else {
        
        orderItems.add(
          OrderItem(
            product: selectedProduct!,
            quantity: quantity,
            clienteOrden: widget.cliente,
          ),
        );
      }

      selectedProduct = null;
      quantityController.clear();
    });

    _showSnackBar('Producto agregado al pedido', isError: false);
  }

  void _removeProduct(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
    _showSnackBar('Producto eliminado', isError: false);
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeProduct(index);
      return;
    }

    if (newQuantity > orderItems[index].product.cantidadRestante) {
      _showSnackBar('Stock insuficiente', isError: true);
      return;
    }

    setState(() {
      orderItems[index].quantity = newQuantity;
    });
  }

  void _confirmOrder() async {
    if (orderItems.isEmpty) {
      _showSnackBar('Agrega productos al pedido', isError: true);
      return;
    }
    var idDespacho = orderItems.first.product.despachoId;

    final userState = context.read<UserProvider>();
    String userToken = '';
    if (userState.status == UserStatus.loaded) {
      userToken = userState.token ?? '';
    }

    // Aquí iría la lógica para guardar el pedido
    final orderData = {
      'detalles': orderItems
          .map(
            (item) => {
              'idProducto': int.parse(item.product.productoId),
              'cantidad': item.quantity,
              'precioUnitario':
                  item.product.precioCliente ?? item.product.precioUnitario,
              if (item.product.precioCliente != null)
                'precioCliente': item.product.precioCliente,
            },
          )
          .toList(),
      'total': totalAmount,
      'tipoPago': selectedPaymentType.name,
      'idCliente': int.parse(widget.cliente.idCliente),
      'idDespacho': int.parse(idDespacho),
      'idChofer': int.parse(userState.usuario!.id),
    };

    final productoVM = context.read<ProductoViewModel>();
    DialogsWidget.showLoading(message: 'Procesando...');
    final success = await productoVM.entregarProductos(orderData, userToken);
    if (mounted) Navigator.pop(context); // cerrar loading
    if (success) {
      context.read<HomeViewModel>().getDataHome(
        userState!.usuario!.id,
        userToken,
      );
      DialogsWidget.showSuccess(
        title: 'Muy bien',
        message: productoVM.msj ?? 'Productos asignados correctamente',
        onClose: () {
          reinicarVenta();
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

  void reinicarVenta() {
    setState(() {
      orderItems.clear();
      selectedProduct = null;
      quantityController.clear();
      selectedPaymentType = PaymentType.contado;
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _loadData() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      userSession = userProvider.usuario;
      context.read<ProductoViewModel>().listarProductosCliente(
        int.parse(userSession!.id),
        int.parse(widget.cliente.idCliente),
        userSession!.accessToken,
      );
    } else {
      print("No hay sesión de usuario activa.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
                if (vm.productosAsignados.isNotEmpty) {
                  productos = vm.productosAsignados;
                }
                return Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Agregar Productos'),
                        const SizedBox(height: 16),
                        _buildProductForm(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Productos en el Pedido'),
                        const SizedBox(height: 4),
                        Text(
                          '$totalItems unidades',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOrderItemsList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Tipo de Pago'),
                        const SizedBox(height: 12),
                        _buildPaymentTypeSelector(),
                        const SizedBox(height: 24),
                        _buildTotalCard(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
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
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppThemeData.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                Text(
                  'Registrar Venta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.cliente.nombreCliente,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppThemeData.primaryColor,
      ),
    );
  }

  Widget _buildProductForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar Producto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppThemeData.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppThemeData.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF5E2C8), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProductoAsignado>(
                value: selectedProduct,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Selecciona un producto...',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_drop_down, color: Color(0xFF6B2A02)),
                ),
                borderRadius: BorderRadius.circular(12),
                items: productos.map((product) {
                  return DropdownMenuItem<ProductoAsignado>(
                    value: product,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
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
                              product.cantidadRestante.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppThemeData.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.producto,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (product.precioCliente == null)
                            Text(
                              '\$${product.precioUnitario.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          if (product.precioCliente != null)
                            Column(
                              children: [
                                Text(
                                  '\$${product.precioCliente!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  'Especial',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (ProductoAsignado? value) {
                  setState(() {
                    selectedProduct = value;
                  });
                },
              ),
            ),
          ),
          if (selectedProduct != null) ...[
            const SizedBox(height: 8),
            Text(
              'Stock disponible: ${selectedProduct!.cantidadRestante} unidades',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Cantidad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppThemeData.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF6B2A02),
                    ),
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
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    'Agregar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeData.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (selectedProduct != null &&
                  selectedProduct!.precioCliente == null)
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showDialogPrice,
                    icon: const Icon(Icons.star, size: 20),
                    label: Text(
                      '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeData.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  _showDialogPrice() {
    if (selectedProduct == null) {
      _showSnackBar('Por favor selecciona un producto primero', isError: true);
      return;
    }

    newPricingController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Precio Especial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Producto: ${selectedProduct!.producto}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Precio actual: \$${selectedProduct!.precioUnitario.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPricingController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Nuevo Precio',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppThemeData.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                newPricingController.clear();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(newPricingController.text);

                if (newPricingController.text.isEmpty) {
                  _showSnackBar('Por favor ingresa un precio', isError: true);
                  return;
                }

                if (newPrice == null || newPrice <= 0) {
                  _showSnackBar('El precio debe ser mayor a 0', isError: true);
                  return;
                }

                setState(() {
                  // Crear nuevo producto con el precio actualizado
                  final updatedProduct = selectedProduct!.copyWith(
                    precioUnitario: newPrice,
                    precioCliente: newPrice,
                  );

                  // Actualizar en la lista de productos para mantener sincronización
                  final index = productos.indexWhere(
                    (p) =>
                        p.idDespachoDetalle == updatedProduct.idDespachoDetalle,
                  );
                  if (index != -1) {
                    productos[index] = updatedProduct;
                  }

                  // Actualizar el producto seleccionado
                  selectedProduct = updatedProduct;
                });

                Navigator.pop(context);

                if (quantityController.text.isNotEmpty) {
                  _addProduct();
                }
                newPricingController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderItemsList() {
    if (orderItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5E2C8), width: 2),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay productos en el pedido',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega productos para crear la venta',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: orderItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildOrderItemCard(item, index);
      }).toList(),
    );
  }

  Widget _buildOrderItemCard(OrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5E2C8), width: 2),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.product.categoria,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.product.producto,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.primaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeProduct(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                iconSize: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _updateQuantity(index, item.quantity - 1);
                      },
                      icon: const Icon(Icons.remove, size: 18),
                      color: AppThemeData.primaryColor,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppThemeData.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _updateQuantity(index, item.quantity + 1);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      color: AppThemeData.primaryColor,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'x \$${item.product.precioUnitario.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentOption(
            PaymentType.contado,
            'Contado',
            Icons.money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentOption(
            PaymentType.credito,
            'Crédito',
            Icons.credit_card,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    PaymentType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedPaymentType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFF5E2C8),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(Icons.check_circle, color: color, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total a Pagar',
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemeData.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalItems productos',
                style: TextStyle(
                  fontSize: 12,
                  color: AppThemeData.primaryColor,
                ),
              ),
            ],
          ),
          Text(
            '\$${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppThemeData.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: orderItems.isEmpty ? null : _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Confirmar Venta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
