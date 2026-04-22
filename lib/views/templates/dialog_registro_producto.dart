import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:Gourmet360/viewmodels/producto_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class DialogRegistroProducto extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSubmit;
  final Usuario userSession;
  const DialogRegistroProducto({
    super.key,
    this.onSubmit,
    required this.userSession,
  });

  @override
  State<DialogRegistroProducto> createState() => _DialogRegistroProductoState();
}

class _DialogRegistroProductoState extends State<DialogRegistroProducto> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategoria;
  final _nombreController = TextEditingController();
  final _precioUnitarioController = TextEditingController();
  final _precioMinimoController = TextEditingController();
  final _costoProduccionController = TextEditingController();

  final List<Map<String, String>> _categorias = [
    {'id': '1', 'nombre': 'Pan'},
    {'id': '2', 'nombre': 'Galletas'},
    {'id': '3', 'nombre': 'Keys'},
    {'id': '4', 'nombre': 'Pastelería'},
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _precioUnitarioController.dispose();
    _precioMinimoController.dispose();
    _costoProduccionController.dispose();
    super.dispose();
  }

  void _generateJson() async {
    if (_formKey.currentState!.validate()) {
      final jsonData = {
        "idCategoria": _selectedCategoria,
        "nombre": _nombreController.text.trim(),
        "precioUnitario": double.parse(_precioUnitarioController.text),
        "precioUnitarioMin": double.parse(_precioMinimoController.text),
        "costoUnitario": double.parse(_costoProduccionController.text),
      };

      final adminVM = context.read<AdminViewModel>();
      DialogsWidget.showLoading(message: 'Procesando...');
      final navigator = Navigator.of(context, rootNavigator: true);
      final success = await adminVM.crearProductoForAdminEndpoint(
        jsonData,
        widget.userSession.accessToken,
      );
      if (!mounted) return;
      navigator.pop();
      if (success) {
        DialogsWidget.showSuccess(
          title: 'Muy bien',
          message: adminVM.msj ?? 'Producto registrado correctamente',
          onClose: () {
            Navigator.pop(context);
            context.read<ProductoViewModel>().listarProductosForAdmin(
              widget.userSession.accessToken,
            );
          },
        );
        return;
      } else {
        DialogsWidget.showError(
          title: 'Atención',
          message: adminVM.msj ?? 'Error desconocido',
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registro de Producto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B2A02),
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Categoría Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategoria,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _categorias
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat['id'],
                              child: Text(cat['nombre']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoria = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Producto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Precio Unitario
                    TextFormField(
                      controller: _precioUnitarioController,
                      decoration: InputDecoration(
                        labelText: 'Precio Unitario',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio unitario es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Precio Mínimo
                    TextFormField(
                      controller: _precioMinimoController,
                      decoration: InputDecoration(
                        labelText: 'Precio Mínimo',

                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio mínimo es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Costo de Producción
                    TextFormField(
                      controller: _costoProduccionController,
                      decoration: InputDecoration(
                        labelText: 'Costo de Producción',

                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El costo de producción es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _generateJson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B2A02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Registrar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
