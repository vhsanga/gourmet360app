import 'package:Gourmet360/core/navigation/app_navigator.dart';
import 'package:Gourmet360/models/cortesias.dart';
import 'package:flutter/material.dart';

class DialogProductosCortesias {
  static void showDialogCortesiasList(List<Cortesias> cortesias) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Productos Cortesias'),
          content: SizedBox(
            width: double.maxFinite,
            child: cortesias.isEmpty
                ? Text('No hay cortesias disponibles.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: cortesias.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final cortesia = cortesias[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(cortesia.nombre),
                        trailing: Chip(
                          label: Text(
                            '${cortesia.cantidad}',
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
