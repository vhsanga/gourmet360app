import 'dart:convert';

class CamionAsignado {
  final String camionId;
  final String camionPlaca;
  final String camionModelo;
  final String camionMarca;
  final String camionCapacidad;
  final String uId;
  final String uNombre;
  final String uCelular;

  CamionAsignado({
    required this.camionId,
    required this.camionPlaca,
    required this.camionModelo,
    required this.camionMarca,
    required this.camionCapacidad,
    required this.uId,
    required this.uNombre,
    required this.uCelular,
  });

  // Factory constructor para crear una instancia desde JSON
  factory CamionAsignado.fromJson(Map<String, dynamic> json) {
    return CamionAsignado(
      camionId: json['camion_id'] ?? '',
      camionPlaca: json['camion_placa'] ?? '',
      camionModelo: json['camion_modelo'] ?? '',
      camionMarca: json['camion_marca'] ?? '',
      camionCapacidad: json['camion_capacidad'] ?? '',
      uId: json['u_id'] ?? '',
      uNombre: json['u_nombre'] ?? '',
      uCelular: json['u_celular'] ?? '',
    );
  }

  // Método para convertir la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'camion_id': camionId,
      'camion_placa': camionPlaca,
      'camion_modelo': camionModelo,
      'camion_marca': camionMarca,
      'camion_capacidad': camionCapacidad,
      'u_id': uId,
      'u_nombre': uNombre,
      'u_celular': uCelular,
    };
  }

  // Método para convertir a string (JSON)
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  // Método para crear una copia con cambios opcionales
  CamionAsignado copyWith({
    String? camionId,
    String? camionPlaca,
    String? camionModelo,
    String? camionMarca,
    String? camionCapacidad,
    String? uId,
    String? uNombre,
    String? uCelular,
  }) {
    return CamionAsignado(
      camionId: camionId ?? this.camionId,
      camionPlaca: camionPlaca ?? this.camionPlaca,
      camionModelo: camionModelo ?? this.camionModelo,
      camionMarca: camionMarca ?? this.camionMarca,
      camionCapacidad: camionCapacidad ?? this.camionCapacidad,
      uId: uId ?? this.uId,
      uNombre: uNombre ?? this.uNombre,
      uCelular: uCelular ?? this.uCelular,
    );
  }
}
