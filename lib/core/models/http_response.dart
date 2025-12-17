import 'dart:convert';

class HttpResponse {
  final bool ok;
  final int statusCode;
  final String mensaje;
  final String timestamp;
  final dynamic data; // Puede ser cualquier tipo (Map, List, String, etc.)
  final int idRequest;

  HttpResponse({
    required this.ok,
    required this.statusCode,
    required this.mensaje,
    required this.timestamp,
    required this.data,
    required this.idRequest,
  });

  // Factory constructor para crear una instancia desde JSON
  factory HttpResponse.fromJson(String str) =>
      HttpResponse.fromMap(json.decode(str));

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory constructor para crear desde un Map
  factory HttpResponse.fromMap(Map<String, dynamic> json) => HttpResponse(
    ok: json["ok"] ?? false,
    statusCode: json["statusCode"] ?? 0,
    mensaje: json["mensaje"] ?? "",
    timestamp: json["timestamp"] ?? "",
    data: json["data"], // Se mantiene como dynamic para aceptar cualquier tipo
    idRequest: json["idRequest"] ?? 0,
  );

  // Método para convertir a Map
  Map<String, dynamic> toMap() => {
    "ok": ok,
    "statusCode": statusCode,
    "mensaje": mensaje,
    "timestamp": timestamp,
    "data": data,
    "idRequest": idRequest,
  };

  // Métodos útiles para trabajar con el campo data
  bool get hasData => data != null;

  // Método para obtener data como un tipo específico (opcional)
  T? getDataAs<T>() {
    try {
      return data as T;
    } catch (e) {
      return null;
    }
  }

  // Método para verificar si data es de un tipo específico
  bool isDataOfType<T>() => data is T;

  @override
  String toString() {
    return 'HttpResponse(ok: $ok, statusCode: $statusCode, mensaje: $mensaje, timestamp: $timestamp, data: $data, idRequest: $idRequest)';
  }
}
