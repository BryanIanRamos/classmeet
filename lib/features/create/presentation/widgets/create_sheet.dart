import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/app_list_row.dart';
import '../../../../core/widgets/layout/app_sheet.dart';

/// The body of the "+" Create overlay (screens 119 and 120).
///
/// Placeholder: task 7.1 builds the real sheet (tool rows with talon costs).
/// For now it offers the quiz wizard and a link to the full Create screen.
/// Each action closes the overlay through [onClose] and then pushes its
/// route.
class CreateSheet extends StatelessWidget {
  const CreateSheet({super.key, required this.onClose});

  final VoidCallback onClose;

  void _go(BuildContext context, String route) {
    onClose();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: AppSheet(
        title: 'Create something',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppListRow(
              title: 'Quizzes',
              subtitle: 'Test your knowledge as you go',
              leadingIcon: AppIcons.clipboardCheck,
              showChevron: true,
              onTap: () => _go(context, Routes.quizSource),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              child: AppButton(
                label: 'See all tools',
                size: AppButtonSize.medium,
                style: AppButtonStyle.clear,
                onPressed: () => _go(context, Routes.create),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
