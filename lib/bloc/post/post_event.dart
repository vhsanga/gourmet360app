import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExecutePost extends PostEvent {
  final Map<String, dynamic> params;
  final String path;
  final String userToken;

  ExecutePost(this.params, this.path, this.userToken);

  @override
  List<Object?> get props => [params, path, userToken];
}
