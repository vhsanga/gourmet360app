import 'package:equatable/equatable.dart';

class EntregaProductoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EntregaProductoInitial extends EntregaProductoState {}

class EntregaProductoLoading extends EntregaProductoState {}

class EntregaProductoSuccess extends EntregaProductoState {
  final String mensaje;
  EntregaProductoSuccess({required this.mensaje});
}

class EntregaProductoFailed extends EntregaProductoState {
  final String error;
  EntregaProductoFailed({required this.error});
}
