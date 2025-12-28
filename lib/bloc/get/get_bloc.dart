import 'package:Gourmet360/bloc/get/get_event.dart';
import 'package:Gourmet360/bloc/get/get_state.dart';
import 'package:Gourmet360/data/http_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetBloc extends Bloc<GetEvent, GetState> {
  final HttpRepository httpRepository;

  GetBloc({required this.httpRepository}) : super(GetInitial()) {
    on<ExecuteGet>(_onExecuted);
  }

  Future<void> _onExecuted(ExecuteGet event, Emitter<GetState> emit) async {
    emit(GetLoading());
    try {
      final httpResponse = await httpRepository.doGet(
        event.path,
        event.params,
        event.userToken,
      );
      emit(GetSuccess(httpResponse));
    } catch (error) {
      emit(GetError(error.toString().replaceAll('Exception:', '')));
    }
  }
}
