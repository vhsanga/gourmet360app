class DashboardVentas {
  final double total_ventas_contado;
  final double total_ventas_credito;
  final double cantidad_vendida;
  final double cantidad_devuelta;

  DashboardVentas({
    required this.total_ventas_contado,
    required this.total_ventas_credito,
    required this.cantidad_vendida,
    required this.cantidad_devuelta,
  });

  factory DashboardVentas.fromJson(Map<String, dynamic> json) {
    return DashboardVentas(
      total_ventas_contado:
          double.tryParse(json['total_ventas_contado']?.toString() ?? '0') ?? 0,
      total_ventas_credito:
          double.tryParse(json['total_ventas_credito']?.toString() ?? '0') ?? 0,
      cantidad_vendida:
          double.tryParse(json['cantidad_vendida']?.toString() ?? '0') ?? 0,
      cantidad_devuelta:
          double.tryParse(json['cantidad_devuelta']?.toString() ?? '0') ?? 0,
    );
  }
}
