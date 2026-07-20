import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get basedUrl => dotenv.env["BASE_URL"]!;
}
