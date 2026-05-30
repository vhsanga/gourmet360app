class VentasTotalesDia {
  final DateTime dia;
  final double totalVentas;
  final double recaudado;
  final double totalEfectivo;
  final double totalTransferencias;
  final double totalDeuda;

  VentasTotalesDia({
    required this.dia,
    required this.totalVentas,
    required this.recaudado,
    required this.totalEfectivo,
    required this.totalTransferencias,
    required this.totalDeuda,
  });

  factory VentasTotalesDia.fromJson(Map<String, dynamic> json) {
    return VentasTotalesDia(
      dia: DateTime.parse(json['dia']),
      totalVentas: double.parse(json['total_ventas']),
      recaudado: double.parse(json['recaudado']),
      totalEfectivo: double.parse(json['total_efectivo']),
      totalTransferencias: double.parse(json['total_transferencias']),
      totalDeuda: double.parse(json['total_deuda']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dia': dia.toIso8601String(),
      'total_ventas': totalVentas.toStringAsFixed(2),
      'recaudado': recaudado.toStringAsFixed(2),
      'total_efectivo': totalEfectivo.toStringAsFixed(2),
      'total_transferencias': totalTransferencias.toStringAsFixed(2),
      'total_deuda': totalDeuda.toStringAsFixed(2),
    };
  }
}
