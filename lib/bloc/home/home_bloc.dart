import 'package:Gourmet360/data/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadClientes>(_onLoadClientes);
  }

  Future<void> _onLoadClientes(
    LoadClientes event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final dataHome = await repository.fetchClientes(idChofer: event.idChofer);
      emit(HomeLoaded(dataHome));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
