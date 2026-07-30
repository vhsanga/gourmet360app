class VentaChoferCreditoHoy {
  final String nombre;
  final double saldoPendiente;
  final DateTime fecha;

  VentaChoferCreditoHoy({
    required this.nombre,
    required this.saldoPendiente,
    required this.fecha,
  });

  factory VentaChoferCreditoHoy.fromJson(Map<String, dynamic> json) {
    return VentaChoferCreditoHoy(
      nombre: _parseString(json['nombre']),
      saldoPendiente: _parseDouble(json['saldo_pendiente']),
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
      'saldo_pendiente': saldoPendiente.toStringAsFixed(2),
      'fecha': fecha.toIso8601String(),
    };
  }

  VentaChoferCreditoHoy copyWith({
    String? nombre,
    double? saldoPendiente,
    DateTime? fecha,
  }) {
    return VentaChoferCreditoHoy(
      nombre: nombre ?? this.nombre,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  String toString() {
    return 'VentaChoferCreditoHoy{nombre: $nombre, saldoPendiente: $saldoPendiente, fecha: $fecha}';
  }
}
