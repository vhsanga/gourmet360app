class DashboardDespachos {
  final double cantidad_asignada;
  final double cantidad_entregada;
  final double cantidad_restante;

  DashboardDespachos({
    required this.cantidad_asignada,
    required this.cantidad_entregada,
    required this.cantidad_restante,
  });

  factory DashboardDespachos.fromJson(Map<String, dynamic> json) {
    return DashboardDespachos(
      cantidad_asignada:
          double.tryParse(json['cantidad_asignada']?.toString() ?? '0') ?? 0,
      cantidad_entregada:
          double.tryParse(json['cantidad_entregada']?.toString() ?? '0') ?? 0,
      cantidad_restante:
          double.tryParse(json['cantidad_restante']?.toString() ?? '0') ?? 0,
    );
  }
}
