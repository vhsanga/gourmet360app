import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadClientes extends HomeEvent {
  final String idChofer;

  LoadClientes(this.idChofer);

  @override
  List<Object?> get props => [idChofer];
}
