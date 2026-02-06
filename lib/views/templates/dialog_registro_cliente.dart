import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/viewmodels/localtion_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogoRegistroCliente extends StatefulWidget {
  final int idChofer;
  final Usuario userSession;

  const DialogoRegistroCliente({
    Key? key,
    required this.idChofer,
    required this.userSession,
  }) : super(key: key);

  @override
  State<DialogoRegistroCliente> createState() => _DialogoRegistroClienteState();
}

class _DialogoRegistroClienteState extends State<DialogoRegistroCliente> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _contactoController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _esClienteEspecial = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _contactoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _guardarCliente() async {
    if (_formKey.currentState!.validate()) {
      final pos = await context.read<LocationViewModel>().getPositionOnce();
      String lat = '';
      String lng = '';
      if (pos != null) {
        lat = pos.latitude.toString();
        lng = pos.longitude.toString();
      }

      final datos = {
        "nombre": _nombreController.text,
        "direccion": _direccionController.text,
        "contacto": _contactoController.text,
        "telefono": _telefonoController.text,
        "id_chofer": widget.idChofer,
        "especial": _esClienteEspecial,
        "lat": lat,
        "lng": lng,
      };

      final choferVM = context.read<ChoferViewModel>();
      DialogsWidget.showLoading(message: 'Procesando...');
      final navigator = Navigator.of(context, rootNavigator: true);
      final success = await choferVM.registrarCliente(
        datos,
        widget.userSession?.accessToken ?? '',
      );
      if (!mounted) return;
      navigator.pop();
      if (success) {
        DialogsWidget.showSuccess(
          title: 'Muy bien',
          message: choferVM.msj ?? 'Cliente registrado correctamente',
          onClose: () {
            Navigator.pop(context);
            context.read<HomeViewModel>().getDataHome(
              widget.userSession!.id,
              widget.userSession!.accessToken,
            );
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
                      'Registrar Cliente',
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

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Distribuidora Central S.A.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    hintText: 'Ej: Av. de los Shyris N34-12 y Portugal',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contacto
                TextFormField(
                  controller: _contactoController,
                  decoration: const InputDecoration(
                    labelText: 'Contacto *',
                    hintText: 'Ej: Ing. Juan Pérez',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El contacto es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    hintText: 'Ej: 0987654321',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El teléfono es requerido';
                    }
                    if (value.length != 10) {
                      return 'El teléfono debe tener 10 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Es cliente especial'),
                  value: _esClienteEspecial,
                  onChanged: (bool? value) {
                    setState(() {
                      _esClienteEspecial = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Botones
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
