import 'package:Gourmet360/core/models/http_response.dart';
import 'package:equatable/equatable.dart';

abstract class PostState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostSuccess extends PostState {
  final HttpResponse response;

  PostSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class PostError extends PostState {
  final String message;

  PostError(this.message);

  @override
  List<Object?> get props => [message];
}
