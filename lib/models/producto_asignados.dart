class ProductoAsignado {
  final String idDespachoDetalle;
  final String despachoId;
  final String productoId;
  final String producto;
  final String categoria;
  final double precioUnitario;
  final double cantidadEntregada;
  final double cantidadRestante;
  final double cantidadAsignada;

  ProductoAsignado({
    required this.idDespachoDetalle,
    required this.despachoId,
    required this.productoId,
    required this.producto,
    required this.categoria,
    required this.precioUnitario,
    required this.cantidadEntregada,
    required this.cantidadRestante,
    required this.cantidadAsignada,
  });

  factory ProductoAsignado.fromJson(Map<String, dynamic> json) {
    return ProductoAsignado(
      idDespachoDetalle: json['id_despacho_detalle'] as String,
      despachoId: json['despacho_id'] as String,
      productoId: json['producto_id'] as String,
      producto: json['producto'] as String,
      categoria: json['categoria'] as String,
      precioUnitario: double.parse(json['precio_unitario'] as String),
      cantidadEntregada: double.parse(json['cantidad_entregada'] as String),
      cantidadRestante: double.parse(json['cantidad_restante'] as String),
      cantidadAsignada: double.parse(json['cantidad_asignada'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDespachoDetalle': idDespachoDetalle,
      'despacho_id': despachoId,
      'producto_id': productoId,
      'producto': producto,
      'categoria': categoria,
      'precio_unitario': precioUnitario.toString(),
      'cantidad_entregada': cantidadEntregada.toString(),
      'cantidad_restante': cantidadRestante.toString(),
      'cantidad_asignada': cantidadAsignada.toString(),
    };
  }

  ProductoAsignado copyWith({
    String? idDespachoDetalle,
    String? despachoId,
    String? productoId,
    String? producto,
    String? categoria,
    double? precioUnitario,
    double? cantidadEntregada,
    double? cantidadRestante,
    double? cantidadAsignada,
  }) {
    return ProductoAsignado(
      idDespachoDetalle: idDespachoDetalle ?? this.idDespachoDetalle,
      despachoId: despachoId ?? this.despachoId,
      productoId: productoId ?? this.productoId,
      producto: producto ?? this.producto,
      categoria: categoria ?? this.categoria,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      cantidadEntregada: cantidadEntregada ?? this.cantidadEntregada,
      cantidadRestante: cantidadRestante ?? this.cantidadRestante,
      cantidadAsignada: cantidadAsignada ?? this.cantidadAsignada,
    );
  }

  @override
  String toString() {
    return 'ProductoAsignado{idDespachoDetalle: $idDespachoDetalle, despachoId:$despachoId,  productoId: $productoId, producto: $producto, categoria: $categoria,  precioUnitario: $precioUnitario, cantidadEntregada: $cantidadEntregada, cantidadRestante: $cantidadRestante, cantidadAsignada: $cantidadAsignada}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductoAsignado &&
          runtimeType == other.runtimeType &&
          idDespachoDetalle == other.idDespachoDetalle &&
          despachoId == other.despachoId &&
          productoId == other.productoId &&
          producto == other.producto &&
          categoria == other.categoria &&
          precioUnitario == other.precioUnitario &&
          cantidadEntregada == other.cantidadEntregada &&
          cantidadRestante == other.cantidadRestante &&
          cantidadAsignada == other.cantidadAsignada;

  @override
  int get hashCode =>
      idDespachoDetalle.hashCode ^
      despachoId.hashCode ^
      productoId.hashCode ^
      producto.hashCode ^
      categoria.hashCode ^
      precioUnitario.hashCode ^
      cantidadEntregada.hashCode ^
      cantidadRestante.hashCode ^
      cantidadAsignada.hashCode;
}
