import 'package:flutter/material.dart';
import 'package:practice1/core/widgets/hex_color.dart';

class AppColor {
  AppColor._();

  static final primary = HexColor('42807F');
  static final secondary = HexColor('0B4F5C');
  static final tertiary = HexColor('74B8BB');

  static final background = HexColor('FFFFFF');

  static final white = HexColor('FFFFFF');
  static final black = HexColor('000000');

  static const success = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
}
