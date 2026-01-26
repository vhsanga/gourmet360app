class Usuario {
  final String id;
  final String nombre;
  final String rol;
  final String celular;
  final int activo;
  final String createdAt;
  final String updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String accessToken;

  Usuario({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.celular,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    required this.accessToken,
  });

  factory Usuario.fromJson(Map<String, dynamic> json, String token) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      rol: json['rol'],
      celular: json['celular'],
      activo: json['activo'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      accessToken: token,
    );
  }

  factory Usuario.fromJsonLocal(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      rol: json['rol'],
      celular: json['celular'],
      activo: json['activo'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      accessToken: json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'rol': rol,
      'celular': celular,
      'activo': activo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'access_token': accessToken,
    };
  }

  // Métodos útiles
  bool get estaActivo => activo == 1;

  bool esRol(String rol) => this.rol.toLowerCase() == rol.toLowerCase();

  // Método para copiar el objeto con cambios
  Usuario copyWith({
    String? id,
    String? nombre,
    String? rol,
    String? celular,
    int? activo,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? accessToken,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      celular: celular ?? this.celular,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre, rol: $rol, celular: $celular, activo: $activo)';
  }
}
