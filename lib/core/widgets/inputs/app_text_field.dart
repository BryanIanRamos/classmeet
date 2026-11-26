import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "Size" axis of the Design System Input (5248:2176), with the
/// measurements of each size.
enum AppTextFieldSize {
  large(
    height: 48,
    radius: AppRadii.sm,
    verticalPadding: AppSpacing.sm,
    textStyle: AppTypography.b1,
  ),
  medium(
    height: 40,
    radius: AppRadii.xs,
    verticalPadding: AppSpacing.xs,
    textStyle: AppTypography.b3,
  );

  const AppTextFieldSize({
    required this.height,
    required this.radius,
    required this.verticalPadding,
    required this.textStyle,
  });

  /// Height of the input box, border included.
  final double height;

  /// Corner radius of the input box.
  final double radius;

  /// Vertical padding; the 24 line of content sits between it.
  final double verticalPadding;

  /// Style of the typed text and the placeholder.
  final TextStyle textStyle;
}

/// Figma "Style" axis of the Design System Input.
enum AppTextFieldStyle { outline, filled }

/// Validation status. The DS shows each as its own "State" (Success, Info,
/// Warning, Error). A non-null `errorText` always means [error].
enum AppTextFieldStatus { none, success, info, warning, error }

/// The ClassMeet text input: label, placeholder, helper or error text, prefix
/// and suffix icons, focus, hover, disabled and validation states.
///
/// [AppTextField.password] adds an eye toggle that shows or hides the text,
/// and [AppTextField.search] adds a leading search icon and a clear button
/// that appears while there is text.
///
/// Geometry is from the DS component (Large 48 / radius 12, Medium 40 /
/// radius 8, padding 12, gap 12, 1.5 stroke drawn inside the edge, label and
/// helper 8 away). Colours and fonts are from the screens, because the DS
/// sheet still shows the UI kit's blue and Inter: kit blue becomes sage-500,
/// kit error red becomes ember-500, success green sprout-500, warning talon,
/// and kit info blue (#0095FF) becomes sky-700. Text uses Plus Jakarta Sans
/// (Body 1 for Large, Body 3 for Medium) and the label Body 4 (screen 96).
/// The stroke is drawn by a [DecoratedBox] around a borderless [TextField]
/// so the geometry is exact. Hover and focus are tracked here; pass a
/// [statesController] to show a state without interaction (galleries,
/// goldens).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.status = AppTextFieldStatus.none,
    this.size = AppTextFieldSize.large,
    this.style = AppTextFieldStyle.outline,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffixSemanticLabel,
    this.accentColor,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.statesController,
  }) : _password = false,
       _search = false;

  /// A password field: text hidden by default, with an eye toggle.
  const AppTextField.password({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.status = AppTextFieldStatus.none,
    this.size = AppTextFieldSize.large,
    this.style = AppTextFieldStyle.outline,
    this.prefixIcon,
    this.accentColor,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.statesController,
  }) : suffixIcon = null,
       onSuffixTap = null,
       suffixSemanticLabel = null,
       obscureText = true,
       keyboardType = TextInputType.visiblePassword,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       autocorrect = false,
       enableSuggestions = false,
       _password = true,
       _search = false;

  /// A search field: leading search icon and a clear button while there is
  /// text.
  const AppTextField.search({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.size = AppTextFieldSize.large,
    this.style = AppTextFieldStyle.outline,
    this.accentColor,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.statesController,
  }) : label = null,
       helperText = null,
       errorText = null,
       status = AppTextFieldStatus.none,
       prefixIcon = AppIcons.search,
       suffixIcon = null,
       onSuffixTap = null,
       suffixSemanticLabel = null,
       obscureText = false,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       autocorrect = true,
       enableSuggestions = true,
       _password = false,
       _search = true;

  /// Box shown by the test finders.
  static const boxKey = ValueKey<String>('AppTextField.box');

  /// Width of the stroke, drawn inside the edge.
  static const borderWidth = 1.5;

  /// Size of the prefix and suffix icons.
  static const iconSize = 24.0;

  /// Line height of the label (screen 96 uses a 16 label row).
  static const labelHeight = 16.0;

  /// Semantic labels of the password toggle.
  static const showPasswordLabel = 'Show password';
  static const hidePasswordLabel = 'Hide password';

  /// Semantic label of the search clear button.
  static const clearLabel = 'Clear';

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? placeholder;
  final String? helperText;

  /// Shown instead of [helperText] in the error colour.
  final String? errorText;
  final AppTextFieldStatus status;
  final AppTextFieldSize size;
  final AppTextFieldStyle style;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? suffixSemanticLabel;

  /// Replaces the idle border, placeholder and icon colour, as the screens
  /// tint the field per section (sage, plume, talon).
  final Color? accentColor;

  /// False disables the field (DS "Disabled").
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Keyboard autocorrect and word suggestions. Turn both off for codes and
  /// usernames (e.g. a class code like ITE16-2026); passwords never use them.
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Extra states (hovered, focused) to show without interaction.
  final WidgetStatesController? statesController;

  final bool _password;
  final bool _search;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  bool _hovered = false;
  bool _focused = false;
  late bool _obscured = widget.obscureText;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focused = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    widget.statesController?.addListener(_onStatesChange);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onTextChange);
      _controller.addListener(_onTextChange);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChange);
      _focusNode.addListener(_onFocusChange);
      _focused = _focusNode.hasFocus;
    }
    if (oldWidget.statesController != widget.statesController) {
      oldWidget.statesController?.removeListener(_onStatesChange);
      widget.statesController?.addListener(_onStatesChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    widget.statesController?.removeListener(_onStatesChange);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() => _focused = _focusNode.hasFocus);

  void _onTextChange() {
    if (widget._search) setState(() {});
  }

  void _onStatesChange() => setState(() {});

  bool _has(WidgetState state, bool real) =>
      real || (widget.statesController?.value.contains(state) ?? false);

  AppTextFieldStatus get _status =>
      widget.errorText != null ? AppTextFieldStatus.error : widget.status;

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.enabled;
    final focused = enabled && _has(WidgetState.focused, _focused);
    final hovered = enabled && _has(WidgetState.hovered, _hovered);
    final palette = _Palette(
      colors: colors,
      status: _status,
      style: widget.style,
      accent: widget.accentColor,
      enabled: enabled,
      focused: focused,
      hovered: hovered,
    );
    final size = widget.size;
    final helper = widget.errorText ?? widget.helperText;

    final box = SizedBox(
      height: size.height,
      child: DecoratedBox(
        key: AppTextField.boxKey,
        decoration: BoxDecoration(
          color: palette.fill,
          borderRadius: BorderRadius.all(Radius.circular(size.radius)),
          border: Border.all(
            color: palette.border,
            width: AppTextField.borderWidth,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              if (widget.prefixIcon case final icon?) ...[
                Icon(icon, size: AppTextField.iconSize, color: palette.icon),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(child: _field(palette)),
              if (_suffix(palette) case final suffix?) ...[
                const SizedBox(width: AppSpacing.sm),
                suffix,
              ],
            ],
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label case final label?) ...[
          SizedBox(
            height: AppTextField.labelHeight,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.b4.copyWith(
                color: colors.textPrimary,
                height: AppTextField.labelHeight / AppTypography.b4.fontSize!,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: enabled ? SystemMouseCursors.text : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? _focusNode.requestFocus : null,
            child: box,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(helper, style: AppTypography.b3.copyWith(color: palette.helper)),
        ],
      ],
    );
  }

  Widget _field(_Palette palette) {
    final style = widget.size.textStyle;
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: style.copyWith(color: palette.text),
      // The caret follows a section accent (e.g. Talon on Join a class).
      cursorColor: widget.accentColor ?? AppColors.sage500,
      cursorHeight: style.fontSize! * 1.25,
      decoration: InputDecoration(
        isCollapsed: true,
        isDense: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: widget.placeholder,
        hintStyle: style.copyWith(color: palette.hint),
      ),
    );
  }

  Widget? _suffix(_Palette palette) {
    if (widget._password) {
      return _IconAction(
        icon: _obscured ? AppIcons.eyeOff : AppIcons.eye,
        color: palette.icon,
        label: _obscured
            ? AppTextField.showPasswordLabel
            : AppTextField.hidePasswordLabel,
        onTap: widget.enabled
            ? () => setState(() => _obscured = !_obscured)
            : null,
      );
    }
    if (widget._search) {
      if (_controller.text.isEmpty) return null;
      return _IconAction(
        icon: AppIcons.x,
        color: palette.icon,
        label: AppTextField.clearLabel,
        onTap: widget.enabled ? _clear : null,
      );
    }
    if (widget.suffixIcon case final icon?) {
      return _IconAction(
        icon: icon,
        color: palette.icon,
        label: widget.suffixSemanticLabel,
        onTap: widget.enabled ? widget.onSuffixTap : null,
      );
    }
    return null;
  }
}

/// A 24 icon that can be tapped.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: label != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Icon(icon, size: AppTextField.iconSize, color: color),
      ),
    );
  }
}

/// The colours of one state, resolved from the DS table.
class _Palette {
  _Palette({
    required this.colors,
    required this.status,
    required this.style,
    required this.accent,
    required this.enabled,
    required this.focused,
    required this.hovered,
  });

  final AppSemanticColors colors;
  final AppTextFieldStatus status;
  final AppTextFieldStyle style;
  final Color? accent;
  final bool enabled;
  final bool focused;
  final bool hovered;

  bool get _hasStatus => enabled && status != AppTextFieldStatus.none;

  Color get _statusColor => switch (status) {
    AppTextFieldStatus.success => AppColors.sprout500,
    AppTextFieldStatus.info => AppColors.sky700,
    AppTextFieldStatus.warning => AppColors.talon500,
    AppTextFieldStatus.error => AppColors.ember500,
    AppTextFieldStatus.none => AppColors.grey200,
  };

  Color get border {
    if (!enabled) return AppColors.grey200;
    if (_hasStatus) return _statusColor;
    if (focused) return AppColors.sage500;
    if (accent != null) return accent!;
    return hovered ? AppColors.grey400 : AppColors.grey200;
  }

  Color get fill {
    if (style == AppTextFieldStyle.outline) return Colors.transparent;
    if (!enabled) return AppColors.grey50;
    if (_hasStatus) {
      return switch (status) {
        AppTextFieldStatus.success => AppColors.sprout50,
        AppTextFieldStatus.info => AppColors.sky50,
        AppTextFieldStatus.warning => AppColors.talon50,
        AppTextFieldStatus.error => AppColors.ember50,
        AppTextFieldStatus.none => AppColors.grey50,
      };
    }
    if (focused) return AppColors.sage50;
    return hovered ? AppColors.grey100 : AppColors.grey50;
  }

  Color get text => enabled ? colors.textPrimary : colors.textGrey;

  Color get hint => (enabled ? accent : null) ?? colors.textGrey;

  Color get icon {
    if (!enabled) return colors.iconLightGrey;
    if (_hasStatus) return _statusColor;
    if (focused) return AppColors.sage500;
    return accent ?? colors.iconGrey;
  }

  Color get helper {
    if (!enabled || !_hasStatus && !focused) return colors.textGrey;
    if (status == AppTextFieldStatus.warning) return AppColors.talon700;
    return _hasStatus ? _statusColor : AppColors.sage500;
  }
}
