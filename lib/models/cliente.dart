class Cliente {
  final String idCliente;
  final String nombreCliente;
  final String direccionCliente;
  final String telefonoCliente;
  final String lat;
  final String lng;
  final bool especial;
  final String observacion;
  final int entregado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.idCliente,
    required this.nombreCliente,
    required this.direccionCliente,
    required this.telefonoCliente,
    required this.lat,
    required this.lng,
    required this.especial,
    required this.observacion,
    required this.createdAt,
    required this.updatedAt,
    required this.entregado,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['idCliente']?.toString() ?? '',
      nombreCliente: json['nombreCliente'] ?? '',
      direccionCliente: json['direccionCliente'] ?? '',
      telefonoCliente: json['telefonoCliente'] ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
      especial: (json['especial'] == 1 || json['especial'] == true)
          ? true
          : false,
      observacion: json['observacion'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      entregado: int.tryParse((json['entregado'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'idCliente': idCliente,
    'nombreCliente': nombreCliente,
    'direccionCliente': direccionCliente,
    'telefonoCliente': telefonoCliente,
    'lat': lat,
    'lng': lng,
    'observacion': observacion,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
