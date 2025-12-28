import 'package:Gourmet360/core/models/http_response.dart';
import 'package:equatable/equatable.dart';

abstract class GetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetInitial extends GetState {}

class GetLoading extends GetState {}

class GetSuccess extends GetState {
  final HttpResponse response;

  GetSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetError extends GetState {
  final String message;

  GetError(this.message);

  @override
  List<Object?> get props => [message];
}
