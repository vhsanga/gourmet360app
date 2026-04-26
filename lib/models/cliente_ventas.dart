class ClienteVentas {
  final String id;
  final int? idVenta;
  final String nombre;
  final String? contacto;
  final String? direccion;
  final String? telefono;
  final double ventaContadoHoy;
  final double dedudaAcumulada;
  final double devolucionHoy;
  final bool especial;

  ClienteVentas({
    required this.id,
    required this.nombre,
    this.idVenta,
    this.contacto,
    this.direccion,
    this.telefono,
    required this.ventaContadoHoy,
    required this.dedudaAcumulada,
    required this.especial,
    this.devolucionHoy = 0.0,
  });

  factory ClienteVentas.fromJson(Map<String, dynamic> json) {
    return ClienteVentas(
      id: _parseString(json['id']),
      nombre: _parseString(json['nombre']),
      idVenta: json['id_venta'] != null
          ? int.tryParse(json['id_venta'].toString())
          : null,
      contacto: _parseString(json['contacto']),
      direccion: _parseString(json['direccion']),
      telefono: _parseString(json['telefono']),
      ventaContadoHoy: _parseDouble(json['venta_contado_hoy']),
      dedudaAcumulada: _parseDouble(json['deuda_acumulada']),
      especial: _parseString(json['especial']) == '0' ? false : true,
      devolucionHoy: _parseDouble(json['devolucion_hoy']),
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
      'contacto': contacto,
      'direccion': direccion,
      'telefono': telefono,
      'venta_contado_hoy': ventaContadoHoy,
      'deduda_acumulada': dedudaAcumulada,
      'id_venta': idVenta,
    };
  }

  ClienteVentas copyWith({
    String? id,
    String? nombre,
    String? contacto,
    String? direccion,
    String? telefono,
    double? ventaContadoHoy,
    double? dedudaAcumulada,
  }) {
    return ClienteVentas(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      ventaContadoHoy: ventaContadoHoy ?? this.ventaContadoHoy,
      dedudaAcumulada: dedudaAcumulada ?? this.dedudaAcumulada,
      especial: especial,
    );
  }

  @override
  String toString() {
    return 'ClienteVentas{id: $id, nombre: $nombre, contacto: $contacto, direccion: $direccion, telefono: $telefono, ventaContadoHoy: $ventaContadoHoy, dedudaAcumulada: $dedudaAcumulada}';
  }
}
