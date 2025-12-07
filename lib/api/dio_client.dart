import 'package:dio/dio.dart';
import 'package:sori/api/rest_client.dart';

import 'package:sori/constants.dart';
import 'package:sori/services/global_storage.dart';

class DioClient {
  late final Dio _dio;
  late final RestClient client;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await GlobalStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    client = RestClient(_dio);
  }
}
