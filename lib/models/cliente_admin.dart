import 'package:Gourmet360/models/cliente.dart';

class ClienteAdmin {
  final String id;
  final String nombre;
  final String direccion;
  final String contacto;
  final String telefono;
  final bool especial;
  final double saldoActual;
  final DateTime fechaRegistro;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String lat;
  final String lng;

  ClienteAdmin({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.contacto,
    required this.telefono,
    required this.especial,
    required this.saldoActual,
    required this.fechaRegistro,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    required this.lat,
    required this.lng,
  });

  factory ClienteAdmin.fromJson(Map<String, dynamic> json) {
    return ClienteAdmin(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      contacto: json['contacto'] ?? '',
      telefono: json['telefono'] ?? '',
      especial: json['especial'] == true || json['especial'] == 1,
      saldoActual: double.tryParse(json['saldoActual']?.toString() ?? '0') ?? 0.0,
      fechaRegistro: DateTime.tryParse(json['fechaRegistro'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
    );
  }

  Cliente toCliente() => Cliente(
    idCliente: id,
    nombreCliente: nombre,
    direccionCliente: direccion,
    telefonoCliente: telefono,
    lat: lat,
    lng: lng,
    especial: especial,
    observacion: contacto,
    entregado: 0,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'direccion': direccion,
    'contacto': contacto,
    'telefono': telefono,
    'especial': especial,
    'saldoActual': saldoActual.toStringAsFixed(2),
    'fechaRegistro': fechaRegistro.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'updatedBy': updatedBy,
    'lat': lat,
    'lng': lng,
  };
}
