import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/usecases/add_user_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsersUseCase getUsersUseCase;
  final AddUserUseCase addUserUseCase;

  UserBloc({
    required this.getUsersUseCase,
    required this.addUserUseCase,
  }) : super(const UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<AddUserEvent>(_onAddUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await getUsersUseCase(
      page: ApiConstants.defaultPage,
      perPage: ApiConstants.defaultPerPage,
    );

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (users) => emit(
        UserLoaded(
          users: users,
          currentPage: ApiConstants.defaultPage,
          hasMore: users.length >= ApiConstants.defaultPerPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) return;

    final currentState = state as UserLoaded;

    // Don't load if already loading or no more data
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    // Show loading indicator
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await getUsersUseCase(
      page: nextPage,
      perPage: ApiConstants.defaultPerPage,
    );

    result.fold(
      (failure) {
        // On error, remove loading indicator
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newUsers) {
        final allUsers = [...currentState.users, ...newUsers];
        emit(
          UserLoaded(
            users: allUsers,
            currentPage: nextPage,
            hasMore: newUsers.length >= ApiConstants.defaultPerPage,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshUsers(
    RefreshUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await getUsersUseCase(
      page: ApiConstants.defaultPage,
      perPage: ApiConstants.defaultPerPage,
    );

    result.fold(
      (failure) {
        // Keep current state on error, just show message
        if (state is UserLoaded) {
          // Could emit a snackbar or toast here
        } else {
          emit(UserError(failure.message));
        }
      },
      (users) => emit(
        UserLoaded(
          users: users,
          currentPage: ApiConstants.defaultPage,
          hasMore: users.length >= ApiConstants.defaultPerPage,
        ),
      ),
    );
  }

  Future<void> _onAddUser(
    AddUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserAdding());

    final result = await addUserUseCase(
      name: event.name,
      email: event.email,
      gender: event.gender,
      status: event.status,
    );

    result.fold(
      (failure) => emit(UserAddError(failure.message)),
      (user) => emit(UserAdded(user)),
    );
  }
}

