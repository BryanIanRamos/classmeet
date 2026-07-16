import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/features/dashboard/dashboard_screen.dart';
import 'package:practice1/features/feed/feed_screen.dart';
import 'package:practice1/features/generate/generate_screen.dart';
import 'package:practice1/features/home/home_screen.dart';
import 'package:practice1/features/messages/message_screen.dart';
import 'package:practice1/features/study/study_screen.dart';
import 'package:practice1/features/welcome_screen.dart';
import 'package:practice1/router/router_names.dart';

void main() {
  runApp(MaterialApp.router(title: 'Material Router', routerConfig: _router));
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: RouterNames.welcome,
      path: '/',
      builder: ((context, state) => WelcomeScreen()),
    ),
    GoRoute(
      name: RouterNames.home,
      path: '/home',
      builder: ((context, state) => HomeScreen()),
    ),
    GoRoute(
      name: RouterNames.dashboard,
      path: '/dashboard',
      builder: ((context, state) => DashboardScreen()),
    ),
    GoRoute(
      name: RouterNames.study,
      path: '/study/:name',
      builder: ((context, state) =>
          StudyScreen(name: state.pathParameters['name']!)),
    ),
    GoRoute(
      name: RouterNames.generate,
      path: '/generate',
      builder: ((context, state) => GenerateScreen()),
    ),
    GoRoute(
      name: RouterNames.feed,
      path: '/feed',
      builder: ((context, state) => FeedScreen()),
    ),
    GoRoute(
      name: RouterNames.messages,
      path: '/message',
      builder: (context, state) => MessageScreen(),
    ),
  ],
);
