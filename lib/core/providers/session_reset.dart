import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:Gourmet360/viewmodels/auth_viewmodel.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/viewmodels/cliente_viewmodel.dart';
import 'package:Gourmet360/viewmodels/home_viewmodel.dart';
import 'package:Gourmet360/viewmodels/localtion_viewmodel.dart';
import 'package:Gourmet360/viewmodels/location_chofer_viemodel.dart';
import 'package:Gourmet360/viewmodels/producto_viewmodel.dart';
import 'package:Gourmet360/viewmodels/ventas_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Limpia los datos de todos los ViewModels globales para que no se mezclen
/// entre sesiones/usuarios. Llamar al cerrar sesión y al iniciar sesión.
class SessionReset {
  SessionReset._();

  static void limpiarTodo(BuildContext context) {
    context.read<AdminViewModel>().limpiarDatos();
    context.read<ChoferViewModel>().limpiarDatos();
    context.read<ClienteViewModel>().limpiarDatos();
    context.read<HomeViewModel>().limpiarDatos();
    context.read<ProductoViewModel>().limpiarDatos();
    context.read<VentasViewModel>().limpiarDatos();
    context.read<LocationViewModel>().limpiarDatos();
    context.read<LocationChoferViewModel>().limpiarDatos();
    context.read<AuthViewModel>().limpiarDatos();
  }
}
