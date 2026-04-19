import 'package:Gourmet360/core/navigation/app_navigator.dart';
import 'package:Gourmet360/models/producto_restante.dart';
import 'package:flutter/material.dart';

class DialogProductosSobrantes {
  static void showDialogSobrantesList(
    List<ProductoRestante> productosRestantes,
  ) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Productos Sobrantes'),
          content: SizedBox(
            width: double.maxFinite,
            child: productosRestantes.isEmpty
                ? Text('No hay sobrantes disponibles.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: productosRestantes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final producto = productosRestantes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(producto.nombre),
                        trailing: Chip(
                          label: Text(
                            '${producto.cantidad_restante}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
