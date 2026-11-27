class ClienteVentas {
  final String id;
  final String nombre;
  final String direccion;
  final double totalVentas;
  final double totalPagado;
  final double totalEfectivo;
  final double totalTransferencia;
  final double deudaTotal;
  final String repartidor;
  final String contacto;

  ClienteVentas({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.totalVentas,
    required this.totalPagado,
    required this.totalEfectivo,
    required this.totalTransferencia,
    required this.deudaTotal,
    required this.repartidor,
    required this.contacto,
  });

  factory ClienteVentas.fromJson(Map<String, dynamic> json) {
    return ClienteVentas(
      id: _parseString(json['id']),
      nombre: _parseString(json['nombre']),
      direccion: _parseString(json['direccion']),
      totalVentas: _parseDouble(json['total_ventas']),
      totalPagado: _parseDouble(json['total_pagado']),
      totalEfectivo: _parseDouble(json['total_efectivo']),
      totalTransferencia: _parseDouble(json['total_transferencia']),
      deudaTotal: _parseDouble(json['deuda_total']),
      repartidor: _parseString(json['repartidor']),
      contacto: _parseString(json['contacto']),
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
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'total_ventas': totalVentas,
      'total_pagado': totalPagado,
      'total_efectivo': totalEfectivo,
      'total_transferencia': totalTransferencia,
      'deuda_total': deudaTotal,
      'contacto': contacto,
    };
  }

  ClienteVentas copyWith({
    String? id,
    String? nombre,
    String? direccion,
    double? totalVentas,
    double? totalPagado,
    double? totalEfectivo,
    double? totalTransferencia,
    double? deudaTotal,
    String? contacto,
    String? repartidor,
  }) {
    return ClienteVentas(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      totalVentas: totalVentas ?? this.totalVentas,
      totalPagado: totalPagado ?? this.totalPagado,
      totalEfectivo: totalEfectivo ?? this.totalEfectivo,
      totalTransferencia: totalTransferencia ?? this.totalTransferencia,
      deudaTotal: deudaTotal ?? this.deudaTotal,
      contacto: contacto ?? this.contacto,
      repartidor: repartidor ?? this.repartidor,
    );
  }

  @override
  String toString() {
    return 'ClienteVentas{id: $id, nombre: $nombre, direccion: $direccion, totalVentas: $totalVentas, totalPagado: $totalPagado, totalEfectivo: $totalEfectivo, totalTransferencia: $totalTransferencia, deudaTotal: $deudaTotal, contacto: $contacto, repartidor: $repartidor}';
  }
}
