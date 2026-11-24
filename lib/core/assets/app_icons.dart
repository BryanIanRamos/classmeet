import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// App icons. Figma uses Lucide (`li:<name>` layers), so each icon maps to a
/// [LucideIcons] glyph. The full audit of Figma names happens in task 2.13.
abstract final class AppIcons {
  static const arrowLeft = LucideIcons.arrowLeft;
  static const arrowRight = LucideIcons.arrowRight;
  static const arrowUp = LucideIcons.arrowUp;
  static const bell = LucideIcons.bell;
  static const bookOpen = LucideIcons.bookOpen;
  static const brain = LucideIcons.brain;
  static const calendarDays = LucideIcons.calendarDays;
  static const chevronRight = LucideIcons.chevronRight;
  static const filePenLine = LucideIcons.filePenLine;
  static const fileText = LucideIcons.fileText;
  static const gamepad2 = LucideIcons.gamepad2;
  static const house = LucideIcons.house;
  static const plus = LucideIcons.plus;
  static const users = LucideIcons.users;

  /// Figma layer name (without the `li:` prefix) → glyph.
  static const Map<String, IconData> byFigmaName = {
    'arrow-left': arrowLeft,
    'arrow-right': arrowRight,
    'arrow-up': arrowUp,
    'bell': bell,
    'book-open': bookOpen,
    'brain': brain,
    'calendar-days': calendarDays,
    'chevron-right': chevronRight,
    'file-pen-line': filePenLine,
    'file-text': fileText,
    'gamepad-2': gamepad2,
    'house': house,
    'plus': plus,
    'users': users,
  };

  /// SVG copies of the Figma icons, kept as fallbacks in case a glyph differs.
  static const svgFallbacks = [
    'assets/icons/bell.svg',
    'assets/icons/book_open.svg',
    'assets/icons/brain.svg',
    'assets/icons/calendar_days.svg',
    'assets/icons/chevron_right.svg',
    'assets/icons/chevron_right_small.svg',
    'assets/icons/file_pen_line.svg',
    'assets/icons/file_text.svg',
    'assets/icons/gamepad_2.svg',
    'assets/icons/house.svg',
    'assets/icons/plus.svg',
    'assets/icons/users.svg',
  ];
}
