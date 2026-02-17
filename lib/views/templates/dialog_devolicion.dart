import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DialogoDevolucion extends StatefulWidget {
  final Cliente cliente;
  final Usuario userSession;
  final Function(String idCliente, int cantidad)? onGuardar;

  const DialogoDevolucion({
    Key? key,
    required this.cliente,
    required this.userSession,
    this.onGuardar,
  }) : super(key: key);

  @override
  State<DialogoDevolucion> createState() => _DialogoDevolucionState();
}

class _DialogoDevolucionState extends State<DialogoDevolucion> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _guardarDevolucion() async {
    if (_formKey.currentState!.validate()) {
      final cantidad = int.parse(_cantidadController.text);

      final choferVM = context.read<ChoferViewModel>();
      DialogsWidget.showLoading(message: 'Procesando...');
      final navigator = Navigator.of(context, rootNavigator: true);
      final success = await choferVM.registrarDevolucionCliente(
        cantidad,
        int.parse(widget.cliente.idCliente),
        int.parse(widget.userSession.id),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
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
                    'Devolución',
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
                  color: Colors.grey[50],
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

              // Campo de cantidad
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad *',
                  hintText: 'Ingrese la cantidad de productos devueltos',
                  prefixIcon: const Icon(Icons.inventory_2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cantidad es requerida';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingrese una cantidad válida mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

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
    );
  }
}
