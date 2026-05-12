import 'package:Gourmet360/models/gastos.dart';
import 'package:flutter/material.dart';

// ─── Modelo para nuevos gastos ───────────────────────────────────────────────

class GastoDialogModel {
  final String? id;
  final TextEditingController detalleCtrl;
  final TextEditingController valorCtrl;

  GastoDialogModel({this.id, String detalle = '', String valor = ''})
    : detalleCtrl = TextEditingController(text: detalle),
      valorCtrl = TextEditingController(text: valor);

  factory GastoDialogModel.fromGasto(Gasto g) => GastoDialogModel(
    id: g.id,
    detalle: g.detalle,
    valor: g.valor > 0 ? g.valor.toStringAsFixed(2) : '',
  );

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
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
  final List<Gasto> gastosExistentes;

  const DialogoRegistroGasto({
    super.key,
    required this.idDespacho,
    required this.idChofer,
    this.gastosExistentes = const [],
  });

  @override
  State<DialogoRegistroGasto> createState() => _DialogoRegistroGastoState();
}

class _DialogoRegistroGastoState extends State<DialogoRegistroGasto> {
  late final List<Gasto> _existentes;
  final List<GastoDialogModel> _nuevos = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _existentes = List.from(widget.gastosExistentes);
    if (_existentes.isEmpty) _agregarNuevo();
  }

  @override
  void dispose() {
    for (final g in _nuevos) g.dispose();
    super.dispose();
  }

  void _agregarNuevo() {
    setState(() => _nuevos.add(GastoDialogModel()));
  }

  void _quitarExistente(int index) {
    setState(() => _existentes.removeAt(index));
  }

  void _quitarNuevo(int index) {
    setState(() {
      _nuevos[index].dispose();
      _nuevos.removeAt(index);
    });
  }

  double get _total {
    final sumExistentes = _existentes.fold(0.0, (s, g) => s + g.valor);
    final sumNuevos = _nuevos.fold(
      0.0,
      (s, g) => s + (double.tryParse(g.valorCtrl.text) ?? 0),
    );
    return sumExistentes + sumNuevos;
  }

  void _guardar() {
    if (_nuevos.isNotEmpty && !_formKey.currentState!.validate()) return;

    final json = {
      'idDespacho': widget.idDespacho,
      'idChofer': widget.idChofer,
      'gastos': [
        ..._existentes.map((g) => {'id': g.id, 'detalle': g.detalle, 'valor': g.valor}),
        ..._nuevos.map((g) => g.toJson()),
      ],
    };

    Navigator.of(context).pop(json);
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_existentes.isNotEmpty) ...[
                        _buildSectionLabel('Gastos registrados'),
                        const SizedBox(height: 8),
                        ..._existentes.asMap().entries.map(
                          (e) => _GastoExistenteItem(
                            gasto: e.value,
                            onDelete: () => _quitarExistente(e.key),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                      ],
                      if (_nuevos.isNotEmpty) ...[
                        _buildSectionLabel('Agregar gastos'),
                        const SizedBox(height: 8),
                        const _ColumnLabels(),
                        const SizedBox(height: 8),
                        ...List.generate(_nuevos.length, (i) {
                          return _GastoNuevoRow(
                            key: ValueKey(_nuevos[i]),
                            gasto: _nuevos[i],
                            canDelete: _nuevos.length > 1 || _existentes.isNotEmpty,
                            onDelete: () => _quitarNuevo(i),
                            onChanged: () => setState(() {}),
                          );
                        }),
                        const SizedBox(height: 4),
                      ],
                      _AgregarButton(onTap: _agregarNuevo),
                    ],
                  ),
                ),
              ),
              _DialogFooter(total: _total, onGuardar: _guardar),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Expanded(
            child: Text(
              'Gastos del día',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total: \$${_total.toStringAsFixed(2)}',
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Item de gasto existente (solo lectura + eliminar) ───────────────────────

class _GastoExistenteItem extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback onDelete;

  const _GastoExistenteItem({required this.gasto, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                gasto.detalle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${gasto.valor.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: colorScheme.error,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(32, 32),
              ),
              tooltip: 'Quitar',
            ),
          ],
        ),
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
        const SizedBox(width: 40),
      ],
    );
  }
}

// ─── Fila editable para nuevo gasto ──────────────────────────────────────────

class _GastoNuevoRow extends StatelessWidget {
  final GastoDialogModel gasto;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _GastoNuevoRow({
    super.key,
    required this.gasto,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    InputDecoration fieldDecoration({String? hint, String? prefix}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixText: prefix,
          prefixStyle: TextStyle(color: colorScheme.onSurface),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.outline, width: 0.5),
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
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: gasto.detalleCtrl,
              decoration: fieldDecoration(hint: 'Ej: Gasolina'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: gasto.valorCtrl,
              decoration: fieldDecoration(hint: '0.00', prefix: '\$ '),
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
          SizedBox(
            width: 36,
            height: 42,
            child: Tooltip(
              message: 'Quitar',
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
        label: const Text('Agregar gasto'),
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
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
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
