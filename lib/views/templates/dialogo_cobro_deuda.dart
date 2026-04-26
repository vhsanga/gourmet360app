import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Diálogo Principal ───────────────────────────────────────────────────────

class DialogoCobroDeuda extends StatefulWidget {
  final int ventaId;

  /// Deuda total pendiente — obligatorio para validar que el cobro no la supere
  final double deudaTotal;

  const DialogoCobroDeuda({
    super.key,
    required this.ventaId,
    required this.deudaTotal,
  });

  @override
  State<DialogoCobroDeuda> createState() => _DialogoCobroDeudaState();
}

class _DialogoCobroDeudaState extends State<DialogoCobroDeuda> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  double get _monto => double.tryParse(_montoCtrl.text.trim()) ?? 0;

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    if (_monto < widget.deudaTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El monto a cobrar no cubre la deuda total')),
      );
      return;
    }

    if (_monto != widget.deudaTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El monto a cobrar no corresponde a la deuda total'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final json = {'ventaId': widget.ventaId, 'monto': _monto};

    // Pequeño delay para feedback visual
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.of(context).pop(json);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(ventaId: widget.ventaId),
              _Body(
                montoCtrl: _montoCtrl,
                deudaTotal: widget.deudaTotal,
                onChanged: () => setState(() {}),
              ),
              _Footer(
                monto: _monto,
                guardando: _guardando,
                onGuardar: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Encabezado ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int ventaId;

  const _Header({required this.ventaId});

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
          // Ícono con fondo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.payments_outlined,
              size: 22,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cobrar deuda',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
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
  final TextEditingController montoCtrl;
  final double deudaTotal;
  final VoidCallback onChanged;

  const _Body({
    required this.montoCtrl,
    required this.deudaTotal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chip deuda total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.errorContainer, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deuda pendiente:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${deudaTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Label
          Text(
            'Valor del cobro',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Campo monto con símbolo grande
          TextFormField(
            controller: montoCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 4),
                child: Text(
                  '\$',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              hintText: '0.00',
              hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.outlineVariant,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa un monto';
              final val = double.tryParse(v.trim());
              if (val == null) return 'Monto inválido';
              if (val <= 0) return 'El monto debe ser mayor a 0';
              if (val > deudaTotal) {
                return 'No puede superar la deuda (\$${deudaTotal.toStringAsFixed(2)})';
              }
              if (val < deudaTotal) {
                return 'No puede ser menor a la deuda (\$${deudaTotal.toStringAsFixed(2)})';
              }
              return null;
            },
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

// ─── Pie del diálogo ──────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final double monto;
  final bool guardando;
  final VoidCallback onGuardar;

  const _Footer({
    required this.monto,
    required this.guardando,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Monto a cobrar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A cobrar',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${monto.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: monto > 0
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Botón cancelar
          TextButton(
            onPressed: guardando ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),

          // Botón cobrar
          FilledButton.icon(
            onPressed: guardando ? null : onGuardar,
            icon: guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(guardando ? 'Guardando...' : 'Cobrar'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cómo usarlo ─────────────────────────────────────────────────────────────
//
//   final result = await showDialog<String>(
//     context: context,
//     builder: (_) => const DialogoCobroDeuda(
//       ventaId: 123,
//       deudaTotal: 150.00,   // obligatorio
//     ),
//   );
//
//   if (result != null) {
//     debugPrint(result);
//     // {"ventaId": 123, "monto": 5.0}
//     // Aquí puedes hacer el POST a tu API
//   }
