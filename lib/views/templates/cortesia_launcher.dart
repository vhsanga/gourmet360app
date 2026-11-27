import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/despacho.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/views/templates/dialog_cortesia.dart';
import 'package:flutter/material.dart';

/// Permite abrir el diálogo de cortesía desde cualquier widget.
class CortesiaLauncher {
  CortesiaLauncher._();

  static Future<T?> mostrar<T>({
    required BuildContext context,
    required Cliente cliente,
    required Usuario userSession,
    required Despacho despacho,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => DialogoCortesia(
        cliente: cliente,
        userSession: userSession,
        despacho: despacho,
      ),
    );
  }
}
