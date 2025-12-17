import 'package:Gourmet360/bloc/entrega_producto/entrega_producto_event.dart';
import 'package:Gourmet360/bloc/entrega_producto/entrega_producto_state.dart';
import 'package:Gourmet360/data/chofer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntregaProductoBloc
    extends Bloc<EntregaProductoEvent, EntregaProductoState> {
  final ChoferRepository repository;

  EntregaProductoBloc({required this.repository})
    : super(EntregaProductoInitial()) {
    on<SubmitEntregaProducto>(_onSaveEntregaProductos);
  }

  Future<void> _onSaveEntregaProductos(
    SubmitEntregaProducto event,
    Emitter<EntregaProductoState> emit,
  ) async {
    emit(EntregaProductoLoading());
    try {
      final response = await repository.saveEntregaProductos(
        event.params,
        event.userToken,
      );
      if (response.ok) {
        emit(EntregaProductoSuccess(mensaje: response.mensaje));
      } else {
        emit(EntregaProductoFailed(error: response.mensaje));
      }
    } catch (e) {
      emit(EntregaProductoFailed(error: e.toString()));
    }
  }
}
