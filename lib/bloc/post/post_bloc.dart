import 'package:Gourmet360/bloc/post/post_state.dart';
import 'package:Gourmet360/bloc/post/post_event.dart';
import 'package:Gourmet360/data/http_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final HttpRepository httpRepository;

  PostBloc({required this.httpRepository}) : super(PostInitial()) {
    on<ExecutePost>(_onExecuted);
  }

  Future<void> _onExecuted(ExecutePost event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final httpResponse = await httpRepository.doPost(
        event.path,
        event.params,
        event.userToken,
      );
      emit(PostSuccess(httpResponse));
    } catch (error) {
      emit(PostError(error.toString().replaceAll('Exception:', '')));
    }
  }
}
