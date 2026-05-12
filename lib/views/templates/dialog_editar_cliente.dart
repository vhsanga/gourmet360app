import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogoEditarCliente extends StatefulWidget {
  final Cliente cliente;
  final Usuario userSession;
  final VoidCallback? onSuccess;

  const DialogoEditarCliente({
    super.key,
    required this.cliente,
    required this.userSession,
    this.onSuccess,
  });

  @override
  State<DialogoEditarCliente> createState() => _DialogoEditarClienteState();
}

class _DialogoEditarClienteState extends State<DialogoEditarCliente> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _direccionController;
  final _contactoController = TextEditingController();
  late final TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente.nombreCliente);
    _direccionController = TextEditingController(text: widget.cliente.direccionCliente);
    _telefonoController = TextEditingController(text: widget.cliente.telefonoCliente);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _contactoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    final datos = {
      "id_cliente": int.tryParse(widget.cliente.idCliente) ?? 0,
      "nombre": _nombreController.text,
      "direccion": _direccionController.text,
      "contacto": _contactoController.text,
      "telefono": _telefonoController.text,
    };

    DialogsWidget.showLoading(message: 'Procesando...');
    final choferVM = context.read<ChoferViewModel>();
    final success = await choferVM.editarliente(
      datos,
      widget.userSession.accessToken,
    );
    if (!mounted) return;
    navigator.pop();

    if (success) {
      DialogsWidget.showSuccess(
        title: 'Muy bien',
        message: choferVM.msj ?? 'Cliente actualizado correctamente',
        onClose: () {
          if (!mounted) return;
          Navigator.pop(context);
          widget.onSuccess?.call();
        },
      );
    } else {
      DialogsWidget.showError(
        title: 'Atención',
        message: choferVM.msj ?? 'Error desconocido',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Editar Cliente',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _direccionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'La dirección es requerida' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactoController,
                  decoration: const InputDecoration(
                    labelText: 'Contacto *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'El contacto es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _guardarCliente,
                      child: const Text('Guardar'),
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
}
