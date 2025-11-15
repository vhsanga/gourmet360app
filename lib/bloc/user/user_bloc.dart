// user_bloc.dart
import 'package:Gourmet360/core/models/usuario.dart';
import 'package:Gourmet360/data/services/local_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UserEvent {}

class LoadUserEvent extends UserEvent {}

class SaveUserEvent extends UserEvent {
  final Usuario usuario;
  SaveUserEvent(this.usuario);
}

class DeleteUserEvent extends UserEvent {}

// States
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Usuario usuario;
  UserLoaded(this.usuario);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserEmpty extends UserState {}

// BLOC
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<SaveUserEvent>(_onSaveUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUser(LoadUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final usuario = await LocalStorageService.getUser();
      if (usuario != null) {
        emit(UserLoaded(usuario));
      } else {
        emit(UserEmpty());
      }
    } catch (e) {
      emit(UserError('Error al cargar usuario: $e'));
    }
  }

  Future<void> _onSaveUser(SaveUserEvent event, Emitter<UserState> emit) async {
    try {
      await LocalStorageService.saveUser(event.usuario);
      emit(UserLoaded(event.usuario));
    } catch (e) {
      emit(UserError('Error al guardar usuario: $e'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      await LocalStorageService.deleteUser();
      emit(UserEmpty());
    } catch (e) {
      emit(UserError('Error al eliminar usuario: $e'));
    }
  }
}
