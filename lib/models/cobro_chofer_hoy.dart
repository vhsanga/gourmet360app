class CobroChoferHoy {
  final String nombre;
  final double valorCobrado;
  final DateTime fechaCobro;

  CobroChoferHoy({
    required this.nombre,
    required this.valorCobrado,
    required this.fechaCobro,
  });

  factory CobroChoferHoy.fromJson(Map<String, dynamic> json) {
    return CobroChoferHoy(
      nombre: _parseString(json['nombre']),
      valorCobrado: _parseDouble(json['valor_cobrado']),
      fechaCobro: _parseDate(json['fecha_cobro']),
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

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'valor_cobrado': valorCobrado.toStringAsFixed(2),
      'fecha_cobro': fechaCobro.toIso8601String(),
    };
  }

  CobroChoferHoy copyWith({
    String? nombre,
    double? valorCobrado,
    DateTime? fechaCobro,
  }) {
    return CobroChoferHoy(
      nombre: nombre ?? this.nombre,
      valorCobrado: valorCobrado ?? this.valorCobrado,
      fechaCobro: fechaCobro ?? this.fechaCobro,
    );
  }

  @override
  String toString() {
    return 'CobroChoferHoy{nombre: $nombre, valorCobrado: $valorCobrado, fechaCobro: $fechaCobro}';
  }
}
