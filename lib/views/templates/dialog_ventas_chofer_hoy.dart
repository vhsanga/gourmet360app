import 'package:Gourmet360/core/navigation/app_navigator.dart';
import 'package:Gourmet360/models/venta_chofer_hoy.dart';
import 'package:flutter/material.dart';

// ─── Diálogo Principal ───────────────────────────────────────────────────────

class DialogVentasChoferHoy {
  static void showDialogVentasList(List<VentaChoferHoy> ventas) {
    final context = AppNavigator.navigatorKey.currentContext!;
    showDialog(
      context: context,
      builder: (_) => _VentasChoferHoyDialog(ventas: ventas),
    );
  }
}

class _VentasChoferHoyDialog extends StatelessWidget {
  final List<VentaChoferHoy> ventas;

  const _VentasChoferHoyDialog({required this.ventas});

  double get _totalEfectivo => ventas.fold(0, (sum, v) => sum + v.efectivo);

  double get _totalTransferencia =>
      ventas.fold(0, (sum, v) => sum + v.transferencia);

  double get _totalGeneral => _totalEfectivo + _totalTransferencia;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Flexible(child: _Body(ventas: ventas)),
            if (ventas.isNotEmpty)
              _Footer(
                totalEfectivo: _totalEfectivo,
                totalTransferencia: _totalTransferencia,
                totalGeneral: _totalGeneral,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Encabezado ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.point_of_sale_outlined,
              size: 22,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ventas de Hoy',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cuerpo ───────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final List<VentaChoferHoy> ventas;

  const _Body({required this.ventas});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (ventas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 36,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay ventas registradas hoy',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      shrinkWrap: true,
      itemCount: ventas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _VentaTile(venta: ventas[index]),
    );
  }
}

class _VentaTile extends StatelessWidget {
  final VentaChoferHoy venta;

  const _VentaTile({required this.venta});

  String get _hora {
    final h = venta.fecha.hour.toString().padLeft(2, '0');
    final m = venta.fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = venta.efectivo + venta.transferencia;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  venta.nombre.isNotEmpty ? venta.nombre[0].toUpperCase() : '?',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venta.nombre,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _hora,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetodoPagoChip(
                  label: 'Efectivo',
                  value: venta.efectivo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetodoPagoChip(
                  label: 'Transferencia',
                  value: venta.transferencia,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetodoPagoChip extends StatelessWidget {
  final String label;
  final double value;

  const _MetodoPagoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label ${value.toStringAsFixed(2)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pie del diálogo ──────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final double totalEfectivo;
  final double totalTransferencia;
  final double totalGeneral;

  const _Footer({
    required this.totalEfectivo,
    required this.totalTransferencia,
    required this.totalGeneral,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Efectivo',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '\$${totalEfectivo.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.swap_horiz,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Transferencia',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '\$${totalTransferencia.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Total',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '\$${totalGeneral.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
