import 'package:flutter/material.dart';
import 'package:practice1/router/route_names.dart';
import 'package:practice1/main_wrapper.dart';
import 'package:practice1/features/home/screens/home_screen.dart';
import 'package:practice1/features/home/screens/dashboard_screen.dart';
import 'package:practice1/features/home/screens/announcement_screen.dart';
import 'package:practice1/features/task/screens/task_screen.dart';
import 'package:practice1/features/task/screens/task_detail_screen.dart';
import 'package:practice1/features/task/screens/create_task_screen.dart';
import 'package:practice1/features/task/screens/edit_task_screen.dart';
import 'package:practice1/features/history/screens/history_screen.dart';
import 'package:practice1/features/history/screens/history_detail_screen.dart';
import 'package:practice1/features/profile/screens/profile_screen.dart';
import 'package:practice1/features/profile/screens/edit_profile_screen.dart';
import 'package:practice1/features/profile/screens/settings_screen.dart';
import 'package:practice1/features/profile/screens/change_password_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MainWrapper());
      case RouteNames.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case RouteNames.announcement:
        return MaterialPageRoute(builder: (_) => const AnnouncementScreen());
      case RouteNames.task:
        return MaterialPageRoute(builder: (_) => const TaskScreen());
      case RouteNames.taskDetail:
        return MaterialPageRoute(builder: (_) => const TaskDetailScreen());
      case RouteNames.createTask:
        return MaterialPageRoute(builder: (_) => const CreateTaskScreen());
      case RouteNames.editTask:
        return MaterialPageRoute(builder: (_) => const EditTaskScreen());
      case RouteNames.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case RouteNames.historyDetail:
        return MaterialPageRoute(builder: (_) => const HistoryDetailScreen());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case RouteNames.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('The page you are looking for does not exist.'),
            ),
          ),
        );
    }
  }
}
