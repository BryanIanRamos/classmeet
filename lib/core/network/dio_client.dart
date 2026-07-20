import 'package:dio/dio.dart';
import 'package:practice1/core/config/env_config.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.basedUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),

        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
