import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/core/router/route_names.dart';
import 'package:practice1/features/auth/screens/home_screen.dart';
import 'package:practice1/features/auth/screens/login_screen.dart';
import 'package:practice1/features/auth/screens/profile_screen.dart';
import 'package:practice1/features/auth/screens/welcome_screen.dart';

abstract final class AppRouter {
  static final GoRouter instance = GoRouter(
    initialLocation: RouteNames.welcome,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.welcome,
        name: 'welcome',
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return LoginScreen();
        },
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return HomeScreen();
        },
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) {
          return ProfileScreen();
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(appBar: AppBar(), body: Text('Page not found!'));
    },
  );
}
