import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final List<User> users;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const UserLoaded({
    required this.users,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  UserLoaded copyWith({
    List<User>? users,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [users, currentPage, hasMore, isLoadingMore];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserAdding extends UserState {
  const UserAdding();
}

class UserAdded extends UserState {
  final User user;

  const UserAdded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserAddError extends UserState {
  final String message;

  const UserAddError(this.message);

  @override
  List<Object?> get props => [message];
}

