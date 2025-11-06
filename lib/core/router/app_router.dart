import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/users/presentation/pages/user_list_screen.dart';
import '../../features/users/presentation/pages/add_user_screen.dart';
import '../../features/device_info/presentation/pages/device_info_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String addUser = '/add-user';
  static const String deviceInfo = '/device-info';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UserListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: addUser,
        name: 'addUser',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddUserScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: deviceInfo,
        name: 'deviceInfo',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DeviceInfoScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}

