import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UserEvent {
  const LoadUsersEvent();
}

class LoadMoreUsersEvent extends UserEvent {
  const LoadMoreUsersEvent();
}

class RefreshUsersEvent extends UserEvent {
  const RefreshUsersEvent();
}

class AddUserEvent extends UserEvent {
  final String name;
  final String email;
  final String gender;
  final String status;

  const AddUserEvent({
    required this.name,
    required this.email,
    required this.gender,
    required this.status,
  });

  @override
  List<Object?> get props => [name, email, gender, status];
}

