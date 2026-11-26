import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/clock.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/display/app_avatar.dart';
import '../../../../core/widgets/navigation/app_navbar_item.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../application/profile_providers.dart';

/// The greeting bar on top of the tab roots (Home 8, Study 92 and 93, and
/// under the Create sheet 119/120, "Navbar Top"): avatar, "Good evening,
/// Bryan!" over "BSIT 2A · CSU", and the bell.
///
/// White under the status bar, 48 + 4 tall with a Grey-100 bottom line
/// (spec 8: 52 with 4 bottom padding). The greeting follows the clock
/// ([greetingFor]) and the username (D-19). Until the profile loads (or when
/// it fails) the greeting has no name, there is no subtitle and the avatar is
/// a neutral person icon. A profile without a picture shows its initial, as
/// people do on Search (12); the sample student has the owl picture of
/// frame 8. The avatar opens Profile, the bell Notifications.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  /// Decode width of a profile picture: the small avatar (32) at 3x.
  static final _avatarCacheWidth = (AppAvatarSize.small.diameter * 3).round();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = greetingFor(ref.watch(clockProvider)());
    final user = ref.watch(profileProvider).value;
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
                onTap: () => context.push(Routes.profile),
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
                onTap: () => context.push(Routes.notifications),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
