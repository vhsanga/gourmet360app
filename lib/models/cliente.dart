class Cliente {
  final String idCliente;
  final String nombreCliente;
  final String direccionCliente;
  final String telefonoCliente;
  final String lat;
  final String lng;
  final String observacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.idCliente,
    required this.nombreCliente,
    required this.direccionCliente,
    required this.telefonoCliente,
    required this.lat,
    required this.lng,
    required this.observacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['idCliente']?.toString() ?? '',
      nombreCliente: json['nombreCliente'] ?? '',
      direccionCliente: json['direccionCliente'] ?? '',
      telefonoCliente: json['telefonoCliente'] ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
      observacion: json['observacion'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
