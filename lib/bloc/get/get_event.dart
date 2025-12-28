import 'package:equatable/equatable.dart';

abstract class GetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExecuteGet extends GetEvent {
  final Map<String, dynamic> params;
  final String path;
  final String userToken;

  ExecuteGet(this.params, this.path, this.userToken);

  @override
  List<Object?> get props => [params, path, userToken];
}
