class DespachosChofer {
  final double cantidad_asignada;
  final double cantidad_entregada;
  final double cantidad_restante;
  final double ventas_credito;
  final double ventas_contado;
  final double efectivo;
  final double transferencia;
  final double cuentas_por_cobrar;
  final double gastos;
  final DateTime fecha;

  DespachosChofer({
    required this.cantidad_asignada,
    required this.cantidad_entregada,
    required this.cantidad_restante,
    required this.ventas_credito,
    required this.ventas_contado,
    required this.efectivo,
    required this.transferencia,
    required this.cuentas_por_cobrar,
    required this.gastos,
    required this.fecha,
  });

  factory DespachosChofer.fromJson(
    Map<String, dynamic> jsonDespachos,
    Map<String, dynamic> jsonVentasHoy,
    Map<String, dynamic> jsonCuentasPorCobrar,
  ) {
    return DespachosChofer(
      cantidad_asignada:
          double.tryParse(
            jsonDespachos['cantidad_asignada']?.toString() ?? '0',
          ) ??
          0,
      cantidad_entregada:
          double.tryParse(
            jsonDespachos['cantidad_entregada']?.toString() ?? '0',
          ) ??
          0,
      cantidad_restante:
          double.tryParse(
            jsonDespachos['cantidad_restante']?.toString() ?? '0',
          ) ??
          0,
      ventas_credito:
          double.tryParse(jsonVentasHoy['ventas_credito']?.toString() ?? '0') ??
          0,
      ventas_contado:
          double.tryParse(jsonVentasHoy['ventas_contado']?.toString() ?? '0') ??
          0,
      efectivo:
          double.tryParse(jsonVentasHoy['efectivo']?.toString() ?? '0') ?? 0,
      transferencia:
          double.tryParse(jsonVentasHoy['transferencia']?.toString() ?? '0') ??
          0,
      cuentas_por_cobrar:
          double.tryParse(
            jsonCuentasPorCobrar['cuentas_por_cobrar']?.toString() ?? '0',
          ) ??
          0,
      gastos: double.tryParse(jsonDespachos['gastos']?.toString() ?? '0') ?? 0,
      fecha:
          DateTime.tryParse(
            jsonDespachos['fechaUltimoDespachoPendiente'] ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
