import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/display/app_avatar.dart';
import '../../../../core/widgets/display/section_header.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../../../core/widgets/selection/app_chip.dart';
import '../../../../data/models/profile.dart';
import '../../../../data/models/search_result.dart';
import '../../../../data/repositories/search_repository.dart';
import '../../application/search_controller.dart';
import '../widgets/search_group_card.dart';
import '../widgets/search_recent_section.dart';

/// Search (frame 12): the field, the All / Classes / Materials / People
/// chips, recent searches and the results grouped by kind.
///
/// Typing searches after a short pause; a recent search fills the field and
/// searches at once. Class rows open the course, material rows the reader.
/// People rows have no designed target yet (GAP-07) and the field's filter
/// icon has none either, so both do nothing.
///
/// [initialQuery] pre-fills the field and searches it at once: the route
/// passes `/home/search?q=…` (also used by tests and the render).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _field = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery;
    if (initial != null && initial.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(homeSearchControllerProvider.notifier)
              .setQuery(initial, immediate: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _pickRecent(String recent) {
    _field.value = TextEditingValue(
      text: recent,
      selection: TextSelection.collapsed(offset: recent.length),
    );
    ref
        .read(homeSearchControllerProvider.notifier)
        .setQuery(recent, immediate: true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(homeSearchControllerProvider.notifier);
    final category = ref.watch(
      homeSearchControllerProvider.select((s) => s.category),
    );
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppNavbarTop(
                title: 'Search',
                onBack: () => Navigator.maybePop(context),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppTextField(
                  controller: _field,
                  placeholder: 'Search materials, classes, people...',
                  prefixIcon: AppIcons.search,
                  suffixIcon: AppIcons.listFilter,
                  // A plain icon: the filter has no designed target yet.
                  suffixSemanticLabel: 'Filter',
                  textInputAction: TextInputAction.search,
                  onChanged: controller.setQuery,
                  onSubmitted: (value) =>
                      controller.setQuery(value, immediate: true),
                ),
              ),
              _CategoryChips(
                selected: category,
                onSelected: controller.selectCategory,
              ),
              Expanded(child: _SearchBody(onPickRecent: _pickRecent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final SearchCategory selected;
  final ValueChanged<SearchCategory> onSelected;

  /// Gap between chips (spec: 10).
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          for (final category in SearchCategory.values) ...[
            if (category != SearchCategory.all) const SizedBox(width: _gap),
            AppChip.choice(
              label: category.label,
              selected: category == selected,
              style: AppChipStyle.tonal,
              onSelected: (_) => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.onPickRecent});

  final ValueChanged<String> onPickRecent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeSearchControllerProvider);
    final controller = ref.read(homeSearchControllerProvider.notifier);
    final recents = ref.watch(recentSearchesProvider).value ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (recents.isNotEmpty) ...[
          SearchRecentSection(
            recents: recents,
            onSelected: onPickRecent,
            onClear: () => ref.read(recentSearchesProvider.notifier).clear(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.hasQuery) ...[
          SectionHeader(
            title: 'Search results',
            actionLabel: 'View all',
            onActionTap: state.category == SearchCategory.all
                ? () => controller.selectCategory(SearchCategory.materials)
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          ..._results(context, state, controller),
        ],
      ],
    );
  }

  List<Widget> _results(
    BuildContext context,
    SearchState state,
    HomeSearchController controller,
  ) {
    final results = state.results;
    final value = results.value;
    if (state.loading && (value == null || value.isEmpty)) {
      return [const Center(child: AppLoader())];
    }
    if (results.hasError && !state.loading) {
      return [ErrorState(onRetry: controller.retry)];
    }
    if (value == null) return const [];
    if (value.isEmpty) {
      return [
        EmptyState(
          title: 'No results for "${state.query.trim()}"',
          message: 'Try another word or category.',
        ),
      ];
    }
    return _groups(context, value);
  }

  List<Widget> _groups(BuildContext context, SearchResults value) {
    final groups = <Widget>[];
    void add(String title, int count, List<Widget> rows) {
      if (count == 0) return;
      if (groups.isNotEmpty) groups.add(const SizedBox(height: AppSpacing.md));
      groups.add(SearchGroupCard(title: title, count: count, rows: rows));
    }

    add('Classes', value.classes.length, [
      for (final r in value.classes)
        SearchResultRow.tile(
          tint: AppColors.plume100,
          title: r.title,
          subtitle: r.subtitle,
          onTap: () => context.push(Routes.course(r.id)),
        ),
    ]);
    add('Materials', value.materials.length, [
      for (var i = 0; i < value.materials.length; i++)
        SearchResultRow.tile(
          tint: i.isEven ? AppColors.plume100 : AppColors.sky100,
          title: value.materials[i].title,
          subtitle: value.materials[i].subtitle,
          onTap: () => context.push(Routes.reader(value.materials[i].id)),
        ),
    ]);
    add('People', value.people.length, [
      for (final p in value.people) _personRow(p),
    ]);
    return groups;
  }

  Widget _personRow(PersonSummary person) {
    final school = person.schoolName;
    final asset = person.avatarAsset;
    return SearchResultRow.person(
      avatar: asset != null
          ? AppAvatar.image(
              imageProvider: ResizeImage(
                AssetImage(asset),
                width: _avatarCacheWidth,
              ),
              size: AppAvatarSize.large,
              showStatus: true,
            )
          : AppAvatar.letter(
              letter: person.name,
              size: AppAvatarSize.large,
              showStatus: true,
              backgroundColor: AppColors.plume300,
            ),
      name: person.name,
      meta: [person.programLabel, ?school],
      // No designed profile page yet (GAP-07).
    );
  }

  /// Decode width of a person's picture: the large avatar (48) at 3x.
  static final _avatarCacheWidth = (AppAvatarSize.large.diameter * 3).round();
}
