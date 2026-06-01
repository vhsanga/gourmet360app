import 'package:Gourmet360/core/navigation/app_navigator.dart';
import 'package:Gourmet360/models/devoluciones.dart';
import 'package:flutter/material.dart';

class DialogProductosDevueltos {
  static void showDialogList(List<Devoluciones> devoluciones) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Productos Devueltos'),
          content: SizedBox(
            width: double.maxFinite,
            child: devoluciones.isEmpty
                ? Text('No hay devoluciones disponibles.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: devoluciones.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final devolucion = devoluciones[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(devolucion.nombre),
                        trailing: Chip(
                          label: Text(
                            '${devolucion.cantidad}',
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
