import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/display/app_avatar.dart';
import '../../../../core/widgets/navigation/app_navbar_item.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../../../data/models/profile.dart';

/// The Home top bar (frame 8, "Navbar Top"): avatar, "Good evening, Bryan!"
/// over "BSIT 2A · CSU", and the bell.
///
/// White under the status bar, 48 + 4 tall with a Grey-100 bottom line
/// (spec 8: 52 with 4 bottom padding). Until the profile loads (or when it
/// fails) the greeting has no name and there is no subtitle. A profile
/// without a picture shows its initial, as people do on Search (12); the
/// sample student has the owl picture of frame 8.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.profile,
    required this.onAvatarTap,
    required this.onNotificationsTap,
  });

  /// "Good evening" (see `greetingFor`).
  final String greeting;
  final UserProfile? profile;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final user = profile;
    final avatarPath = user?.avatarAsset;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        border: const Border(bottom: BorderSide(color: AppColors.grey100)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: AppNavbarTop(
            avatar: Semantics(
              button: true,
              label: 'Profile',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAvatarTap,
                child: switch ((user, avatarPath)) {
                  // Still loading, or failed: a neutral person icon.
                  (null, _) => const AppAvatar.icon(icon: AppIcons.user),
                  (final user?, null) => AppAvatar.letter(
                    letter: user.username,
                  ),
                  (_, final path?) => AppAvatar.image(
                    imageProvider: ResizeImage(
                      AssetImage(path),
                      width: _avatarCacheWidth,
                    ),
                  ),
                },
              ),
            ),
            title: user == null ? '$greeting!' : '$greeting, ${user.username}!',
            subtitle: user == null
                ? null
                : '${user.programLabel} · ${user.schoolShort}',
            trailing: [
              AppNavbarItem.icon(
                icon: AppIcons.bell,
                semanticLabel: 'Notifications',
                onTap: onNotificationsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Decode width of a profile picture: the small avatar (32) at 3x.
  static final _avatarCacheWidth = (AppAvatarSize.small.diameter * 3).round();
}
