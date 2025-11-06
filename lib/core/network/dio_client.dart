import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_constants.dart';
import '../database/database_helper.dart';

@module
abstract class DioModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();
  
  @lazySingleton
  DatabaseHelper get databaseHelper => DatabaseHelper.instance;

  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Authorization': 'Bearer ${ApiConstants.bearerToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          // In production, you might want to use a proper logging framework
          print(obj);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle specific error cases
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            print('Unauthorized: Invalid or expired token');
          } else if (error.response?.statusCode == 422) {
            // Validation error (e.g., duplicate email)
            print('Validation error: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}

