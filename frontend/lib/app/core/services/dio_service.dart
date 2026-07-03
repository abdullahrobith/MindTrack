import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class DioService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );
}