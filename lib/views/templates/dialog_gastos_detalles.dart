import 'package:Gourmet360/core/navigation/app_navigator.dart';
import 'package:Gourmet360/models/gastos.dart';
import 'package:flutter/material.dart';

class DialogoGastosDetalles {
  static void showDialogGastosList(List<Gasto> gastos) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Detalle de gastos'),
          content: SizedBox(
            width: double.maxFinite,
            child: gastos.isEmpty
                ? Text('No hay gastos disponibles.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: gastos.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final gasto = gastos[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(gasto.detalle),
                        trailing: Chip(
                          label: Text(
                            '\$${gasto.valor.toStringAsFixed(2)}',
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
