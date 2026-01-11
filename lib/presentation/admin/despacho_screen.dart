import 'package:Gourmet360/bloc/get/get_bloc.dart';
import 'package:Gourmet360/bloc/get/get_event.dart';
import 'package:Gourmet360/bloc/get/get_state.dart';
import 'package:Gourmet360/bloc/post/post_bloc.dart';
import 'package:Gourmet360/bloc/post/post_event.dart';
import 'package:Gourmet360/bloc/post/post_state.dart';
import 'package:Gourmet360/bloc/user/user_bloc.dart';
import 'package:Gourmet360/core/models/camion_asignado.dart';
import 'package:Gourmet360/core/models/producto.dart';
import 'package:Gourmet360/data/http_repository.dart';
import 'package:Gourmet360/presentation/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DespachoScreen extends StatefulWidget {
  CamionAsignado? camionAsignado;
  DespachoScreen({Key? key, required this.camionAsignado}) : super(key: key);

  @override
  State<DespachoScreen> createState() => _DespachoScreenState();
}

class _DespachoScreenState extends State<DespachoScreen> {
  List<Producto> _productos = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar controladores para cada producto
    for (var product in _productos) {
      _controllers[product.id.toString()] = TextEditingController();
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
    final userState = context.read<UserBloc>().state;
    String userToken = '';
    if (userState is UserLoaded) {
      userToken = userState.usuario.accessToken;
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<GetBloc>(
          create: (context) {
            return GetBloc(httpRepository: HttpRepository())
              ..add(ExecuteGet({}, '/admin/productos', userToken));
          },
        ),
        BlocProvider<PostBloc>(
          create: (context) {
            return PostBloc(httpRepository: HttpRepository());
          },
        ),
      ],

      child: Scaffold(
        appBar: AppBar(
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
                              color: const Color(0xFF6B2A02),
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
          backgroundColor: const Color(0xFF6B2A02),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<GetBloc, GetState>(
          listener: (context, state) {
            if (state is GetSuccess) {
              setState(() {
                _productos = state.response.data
                    .map((e) => Producto.fromJson(e as Map<String, dynamic>))
                    .toList()
                    .cast<Producto>();
              });
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChoferCard(),
                      SizedBox(height: 20),
                      _buildProductsList(),

                      const SizedBox(height: 60),
                      if (_itemsAsignados.isNotEmpty) _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              ? const Color(0xFF6B2A02)
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
                                color: const Color(0xFF6B2A02),
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
                              color: const Color(0xFF6B2A02),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cantidad',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: const Color(0xFFFFFCF5),
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
                                  color: const Color(0xFF6B2A02),
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
                  backgroundColor: const Color(0xFF6B2A02),
                  foregroundColor: const Color(0xFFFFFCF5),
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

    final userState = context.read<UserBloc>().state;
    String userToken = '';
    if (userState is UserLoaded) {
      userToken = userState.usuario.accessToken;
    }
    final postBloc = BlocProvider.of<PostBloc>(context);
    postBloc.add(ExecutePost(data, '/admin/create-despacho', userToken));
    await for (final state in postBloc.stream) {
      if (state is PostLoading) {
        DialogsWidget.showLoading(context, message: 'Procesando...');
      }

      if (state is PostSuccess) {
        Navigator.pop(context);
        DialogsWidget.showSuccess(
          context,
          title: 'Muy bien',
          message: 'Productos asignados correctamente',
          onClose: () {
            for (final p in _productos) {
              p.cantidad = 0;
            }
            Navigator.pop(context);
          },
        );
      }

      if (state is PostError) {
        Navigator.pop(context);
        DialogsWidget.showError(
          context,
          title: 'Atención',
          message: state.message,
        );
      }
    }
  }
}
