class ClienteVentaDia {
  final int idVenta;
  final String dia;
  final double totalContado;
  final double totalDeuda;
  final double totalPagado;
  final double totalVenta;

  ClienteVentaDia({
    required this.idVenta,
    required this.dia,
    required this.totalContado,
    required this.totalDeuda,
    required this.totalPagado,
    required this.totalVenta,
  });

  factory ClienteVentaDia.fromJson(Map<String, dynamic> json) {
    return ClienteVentaDia(
      idVenta: json['id_venta'] != null
          ? int.tryParse(json['id_venta'].toString())!
          : 0,
      dia: _parseString(json['dia']),
      totalContado: _parseDouble(json['total_contado']),
      totalDeuda: _parseDouble(json['total_credito']),
      totalPagado: _parseDouble(json['total_pagado']),
      totalVenta: _parseDouble(json['valor_venta']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id_venta': idVenta,
      'dia': dia,
      'total_contado': totalContado,
      'total_credito': totalDeuda,
    };
  }

  ClienteVentaDia copyWith({
    String? dia,
    int? idVenta,
    double? totalContado,
    double? totalDeuda,
    double? totalPagado,
    double? totalVenta,
  }) {
    return ClienteVentaDia(
      dia: dia ?? this.dia,
      idVenta: idVenta ?? this.idVenta,
      totalContado: totalContado ?? this.totalContado,
      totalDeuda: totalDeuda ?? this.totalDeuda,
      totalPagado: totalPagado ?? this.totalPagado,
      totalVenta: totalVenta ?? this.totalVenta,
    );
  }

  @override
  String toString() {
    return 'ClienteVentaDia{dia: $dia, totalContado: $totalContado, totalDeuda: $totalDeuda}';
  }
}
