import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/user_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_widget.dart' as app_widgets;

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserBloc>()..add(const LoadUsersEvent()),
      child: const _UserListScreenContent(),
    );
  }
}

class _UserListScreenContent extends StatefulWidget {
  const _UserListScreenContent();

  @override
  State<_UserListScreenContent> createState() => _UserListScreenContentState();
}

class _UserListScreenContentState extends State<_UserListScreenContent> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<UserBloc>().add(const LoadMoreUsersEvent());
    }
  }

  void _onRefresh() {
    context.read<UserBloc>().add(const RefreshUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.push(AppRouter.deviceInfo);
            },
            tooltip: 'Device Info',
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            _refreshController.refreshCompleted();
          } else if (state is UserError) {
            _refreshController.refreshFailed();
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const LoadingShimmer();
          }

          if (state is UserError) {
            return app_widgets.ErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<UserBloc>().add(const LoadUsersEvent());
              },
            );
          }

          if (state is UserLoaded) {
            if (state.users.isEmpty) {
              return const EmptyState(
                message: 'No users found',
                icon: Icons.people_outline,
              );
            }

            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.users.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  final user = state.users[index];
                  return UserCard(user: user);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push(AppRouter.addUser);
          if (result == true && context.mounted) {
            context.read<UserBloc>().add(const RefreshUsersEvent());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
    );
  }
}

