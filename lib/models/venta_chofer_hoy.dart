class VentaChoferHoy {
  final String nombre;
  final double efectivo;
  final double transferencia;
  final DateTime fecha;

  VentaChoferHoy({
    required this.nombre,
    required this.efectivo,
    required this.transferencia,
    required this.fecha,
  });

  factory VentaChoferHoy.fromJson(Map<String, dynamic> json) {
    return VentaChoferHoy(
      nombre: _parseString(json['nombre']),
      efectivo: _parseDouble(json['efectivo']),
      transferencia: _parseDouble(json['transferencia']),
      fecha: _parseDate(json['fecha']),
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
      'efectivo': efectivo.toStringAsFixed(2),
      'transferencia': transferencia.toStringAsFixed(2),
      'fecha': fecha.toIso8601String(),
    };
  }

  VentaChoferHoy copyWith({
    String? nombre,
    double? efectivo,
    double? transferencia,
    DateTime? fecha,
  }) {
    return VentaChoferHoy(
      nombre: nombre ?? this.nombre,
      efectivo: efectivo ?? this.efectivo,
      transferencia: transferencia ?? this.transferencia,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  String toString() {
    return 'VentaChoferHoy{nombre: $nombre, efectivo: $efectivo, transferencia: $transferencia, fecha: $fecha}';
  }
}
