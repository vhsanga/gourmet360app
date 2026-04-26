import 'dart:convert';
import 'package:flutter/material.dart';

// ─── Modelo de Gasto ────────────────────────────────────────────────────────

class Gasto {
  final TextEditingController detalleCtrl;
  final TextEditingController valorCtrl;

  Gasto()
    : detalleCtrl = TextEditingController(),
      valorCtrl = TextEditingController();

  Map<String, dynamic> toJson({
    required int idDespacho,
    required int idChofer,
  }) {
    return {
      'idDespacho': idDespacho,
      'idChofer': idChofer,
      'detalle': detalleCtrl.text.trim(),
      'valor': double.tryParse(valorCtrl.text.trim()) ?? 0,
    };
  }

  void dispose() {
    detalleCtrl.dispose();
    valorCtrl.dispose();
  }
}

// ─── Diálogo Principal ───────────────────────────────────────────────────────

class DialogoRegistroGasto extends StatefulWidget {
  final int idDespacho;
  final int idChofer;

  const DialogoRegistroGasto({
    super.key,
    required this.idDespacho,
    required this.idChofer,
  });

  @override
  State<DialogoRegistroGasto> createState() => _DialogoRegistroGastoState();
}

class _DialogoRegistroGastoState extends State<DialogoRegistroGasto> {
  final List<Gasto> _gastos = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _agregarGasto(); // Comienza con una fila
  }

  @override
  void dispose() {
    for (final g in _gastos) g.dispose();
    super.dispose();
  }

  void _agregarGasto() {
    setState(() => _gastos.add(Gasto()));
  }

  void _quitarGasto(int index) {
    setState(() {
      _gastos[index].dispose();
      _gastos.removeAt(index);
    });
  }

  double get _total {
    return _gastos.fold(0, (sum, g) {
      return sum + (double.tryParse(g.valorCtrl.text) ?? 0);
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final json = {
      'gastos': _gastos
          .map(
            (g) => g.toJson(
              idDespacho: widget.idDespacho,
              idChofer: widget.idChofer,
            ),
          )
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('    ').convert(json);

    // Cierra el diálogo y devuelve el JSON generado
    Navigator.of(context).pop(json);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Encabezado ──────────────────────────────────────────────
              _DialogHeader(
                idDespacho: widget.idDespacho,
                idChofer: widget.idChofer,
                total: _total,
              ),

              // ── Cuerpo con filas de gastos ───────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      // Etiquetas de columna
                      const _ColumnLabels(),
                      const SizedBox(height: 8),

                      // Lista de filas
                      ...List.generate(_gastos.length, (i) {
                        return _GastoRow(
                          key: ValueKey(_gastos[i]),
                          gasto: _gastos[i],
                          index: i,
                          canDelete: _gastos.length > 1,
                          onDelete: () => _quitarGasto(i),
                          onChanged: () => setState(() {}),
                        );
                      }),

                      // Botón agregar
                      const SizedBox(height: 8),
                      _AgregarButton(onTap: _agregarGasto),
                    ],
                  ),
                ),
              ),

              // ── Pie: total + botón guardar ───────────────────────────
              _DialogFooter(total: _total, onGuardar: _guardar),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Encabezado ──────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final int idDespacho;
  final int idChofer;
  final double total;

  const _DialogHeader({
    required this.idDespacho,
    required this.idChofer,
    required this.total,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar gastos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
          // Badge total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Etiquetas de columna ─────────────────────────────────────────────────────

class _ColumnLabels extends StatelessWidget {
  const _ColumnLabels();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: 0.4,
    );

    return Row(
      children: [
        Expanded(child: Text('DETALLE', style: style)),
        const SizedBox(width: 10),
        SizedBox(width: 120, child: Text('VALOR (\$)', style: style)),
        const SizedBox(width: 40), // espacio para el botón quitar
      ],
    );
  }
}

// ─── Fila de gasto ────────────────────────────────────────────────────────────

class _GastoRow extends StatelessWidget {
  final Gasto gasto;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _GastoRow({
    super.key,
    required this.gasto,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo detalle
          Expanded(
            child: TextFormField(
              controller: gasto.detalleCtrl,
              decoration: InputDecoration(
                hintText: 'Ej: Gasolina',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.error, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                isDense: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 10),

          // Campo valor
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: gasto.valorCtrl,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: colorScheme.onSurface),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.error, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (double.tryParse(v.trim()) == null) return 'Inválido';
                return null;
              },
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),

          // Botón quitar
          SizedBox(
            width: 36,
            height: 42,
            child: Tooltip(
              message: 'Quitar gasto',
              child: IconButton(
                onPressed: canDelete ? onDelete : null,
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 20,
                  color: canDelete
                      ? colorScheme.error
                      : colorScheme.outlineVariant,
                ),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: canDelete
                          ? colorScheme.errorContainer
                          : colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón agregar ────────────────────────────────────────────────────────────

class _AgregarButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AgregarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
        label: const Text('Agregar otro gasto'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
            style: BorderStyle.solid,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ─── Pie del diálogo ──────────────────────────────────────────────────────────

class _DialogFooter extends StatelessWidget {
  final double total;
  final VoidCallback onGuardar;

  const _DialogFooter({required this.total, required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Total
          const Spacer(),

          // Botón cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),

          // Botón guardar
          FilledButton.icon(
            onPressed: onGuardar,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Guardar'),
            style: FilledButton.styleFrom(
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
