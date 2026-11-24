import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// App icons. Figma uses Lucide (`li:<name>` layers), so each icon maps to a
/// [LucideIcons] glyph with the same name in camelCase. The 2.13 audit found
/// 56 names across the 43 screen specs, and every one exists in
/// lucide_icons_flutter 4 under its own name (no renames needed).
/// One exception shares a glyph: Figma's `layers-3` (Flashcards) is the older
/// Lucide drawing, which current Lucide aliases to `layers` (INC-10).
///
/// Stroke: the screens use Lucide's stroke 2 on a 24-unit box, scaled with the
/// icon (16px icons measure 1.33 wide), which is exactly how the regular
/// [LucideIcons] font scales. Don't use the `LucideIcons100…600` weights.
///
/// A few extra glyphs are used inside widgets only (arrows, eye, minus, smile,
/// user). DS kit sheets use Iconoir names; their Lucide equivalents:
/// nav-arrow-* → chevron-*, cancel → x, emoji → smile.
abstract final class AppIcons {
  static const alignLeft = LucideIcons.alignLeft;
  static const arrowLeft = LucideIcons.arrowLeft;
  static const arrowRight = LucideIcons.arrowRight;
  static const arrowUp = LucideIcons.arrowUp;
  static const bell = LucideIcons.bell;
  static const bookOpen = LucideIcons.bookOpen;
  static const brain = LucideIcons.brain;
  static const calendarDays = LucideIcons.calendarDays;
  static const camera = LucideIcons.camera;
  static const chartNoAxesColumnIncreasing =
      LucideIcons.chartNoAxesColumnIncreasing;
  static const check = LucideIcons.check;
  static const chevronDown = LucideIcons.chevronDown;
  static const chevronLeft = LucideIcons.chevronLeft;
  static const chevronRight = LucideIcons.chevronRight;
  static const chevronsUpDown = LucideIcons.chevronsUpDown;
  static const circleCheck = LucideIcons.circleCheck;
  static const circleX = LucideIcons.circleX;
  static const clipboardCheck = LucideIcons.clipboardCheck;
  static const clipboardPaste = LucideIcons.clipboardPaste;
  static const clock7 = LucideIcons.clock7;
  static const coins = LucideIcons.coins;
  static const eye = LucideIcons.eye;
  static const eyeOff = LucideIcons.eyeOff;
  static const fileImage = LucideIcons.fileImage;
  static const filePen = LucideIcons.filePen;
  static const filePenLine = LucideIcons.filePenLine;
  static const fileText = LucideIcons.fileText;
  static const flame = LucideIcons.flame;
  static const gamepad2 = LucideIcons.gamepad2;
  static const gift = LucideIcons.gift;
  static const heart = LucideIcons.heart;
  static const house = LucideIcons.house;
  static const info = LucideIcons.info;
  static const layers = LucideIcons.layers;
  static const libraryBig = LucideIcons.libraryBig;
  static const lightbulb = LucideIcons.lightbulb;
  static const listFilter = LucideIcons.listFilter;
  static const minus = LucideIcons.minus;
  static const network = LucideIcons.network;
  static const notebookPen = LucideIcons.notebookPen;
  static const plus = LucideIcons.plus;
  static const reply = LucideIcons.reply;
  static const scanLine = LucideIcons.scanLine;
  static const search = LucideIcons.search;
  static const sendHorizontal = LucideIcons.sendHorizontal;
  static const shieldCheck = LucideIcons.shieldCheck;
  static const skipBack = LucideIcons.skipBack;
  static const skipForward = LucideIcons.skipForward;
  static const smile = LucideIcons.smile;
  static const sparkles = LucideIcons.sparkles;
  static const squarePen = LucideIcons.squarePen;
  static const star = LucideIcons.star;
  static const swords = LucideIcons.swords;
  static const trash2 = LucideIcons.trash2;
  static const trendingUp = LucideIcons.trendingUp;
  static const trophy = LucideIcons.trophy;
  static const upload = LucideIcons.upload;
  static const user = LucideIcons.user;
  static const users = LucideIcons.users;
  static const venetianMask = LucideIcons.venetianMask;
  static const wifiOff = LucideIcons.wifiOff;
  static const x = LucideIcons.x;
  static const zap = LucideIcons.zap;

  /// Figma layer name (without the `li:` prefix) → glyph.
  static const Map<String, IconData> byFigmaName = {
    'align-left': alignLeft,
    'arrow-left': arrowLeft,
    'arrow-right': arrowRight,
    'arrow-up': arrowUp,
    'bell': bell,
    'book-open': bookOpen,
    'brain': brain,
    'calendar-days': calendarDays,
    'camera': camera,
    'chart-no-axes-column-increasing': chartNoAxesColumnIncreasing,
    'check': check,
    'chevron-down': chevronDown,
    'chevron-left': chevronLeft,
    'chevron-right': chevronRight,
    'chevrons-up-down': chevronsUpDown,
    'circle-check': circleCheck,
    'circle-x': circleX,
    'clipboard-check': clipboardCheck,
    'clipboard-paste': clipboardPaste,
    'clock-7': clock7,
    'coins': coins,
    'eye': eye,
    'eye-off': eyeOff,
    'file-image': fileImage,
    'file-pen': filePen,
    'file-pen-line': filePenLine,
    'file-text': fileText,
    'flame': flame,
    'gamepad-2': gamepad2,
    'gift': gift,
    'heart': heart,
    'house': house,
    'info': info,
    'layers': layers,
    'layers-3': layers,
    'library-big': libraryBig,
    'lightbulb': lightbulb,
    'list-filter': listFilter,
    'minus': minus,
    'network': network,
    'notebook-pen': notebookPen,
    'plus': plus,
    'reply': reply,
    'scan-line': scanLine,
    'search': search,
    'send-horizontal': sendHorizontal,
    'shield-check': shieldCheck,
    'skip-back': skipBack,
    'skip-forward': skipForward,
    'smile': smile,
    'sparkles': sparkles,
    'square-pen': squarePen,
    'star': star,
    'swords': swords,
    'trash-2': trash2,
    'trending-up': trendingUp,
    'trophy': trophy,
    'upload': upload,
    'user': user,
    'users': users,
    'venetian-mask': venetianMask,
    'wifi-off': wifiOff,
    'x': x,
    'zap': zap,
  };

  /// Figma names that deliberately share another name's glyph.
  static const aliasedFigmaNames = {'layers-3'};

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
