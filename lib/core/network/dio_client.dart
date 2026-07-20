import 'package:dio/dio.dart';
import 'package:practice1/core/config/env_config.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.basedUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),

        headers: {
          "Accept": 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
