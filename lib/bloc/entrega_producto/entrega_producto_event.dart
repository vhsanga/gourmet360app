import 'package:equatable/equatable.dart';

abstract class EntregaProductoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitEntregaProducto extends EntregaProductoEvent {
  final Map<String, dynamic> params;
  final String userToken;

  SubmitEntregaProducto(this.params, this.userToken);

  @override
  List<Object?> get props => [params, userToken];
}
