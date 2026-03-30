class ClienteVentaDia {
  final String dia;
  final double totalContado;
  final double totalCredito;

  ClienteVentaDia({
    required this.dia,
    required this.totalContado,
    required this.totalCredito,
  });

  factory ClienteVentaDia.fromJson(Map<String, dynamic> json) {
    return ClienteVentaDia(
      dia: _parseString(json['dia']),
      totalContado: _parseDouble(json['total_contado']),
      totalCredito: _parseDouble(json['total_credito']),
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
      'dia': dia,
      'total_contado': totalContado,
      'total_credito': totalCredito,
    };
  }

  ClienteVentaDia copyWith({
    String? dia,
    double? totalContado,
    double? totalCredito,
  }) {
    return ClienteVentaDia(
      dia: dia ?? this.dia,
      totalContado: totalContado ?? this.totalContado,
      totalCredito: totalCredito ?? this.totalCredito,
    );
  }

  @override
  String toString() {
    return 'ClienteVentaDia{dia: $dia, totalContado: $totalContado, totalCredito: $totalCredito}';
  }
}
