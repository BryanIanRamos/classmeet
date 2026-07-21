import 'package:dio/dio.dart';
import 'package:practice1/features/models/user_login_model.dart';

class UserLoginApi {
  late final Dio dio;

  UserLoginApi(this.dio);

  Future<List<UserLoginModel>> userLogin() async {
    final response = await dio.get('/login');

    return
  }
}
