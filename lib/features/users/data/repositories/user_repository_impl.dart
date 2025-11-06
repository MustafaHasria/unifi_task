import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/create_user_request.dart';
import '../services/user_api_service.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserApiService apiService;

  UserRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<User>>> getUsers(int page, int perPage) async {
    try {
      final userModels = await apiService.getUsersPaginated(page, perPage);
      final users = userModels.map((model) => model.toEntity()).toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> addUser({
    required String name,
    required String email,
    required String gender,
    required String status,
  }) async {
    try {
      final request = CreateUserRequest(
        name: name,
        email: email,
        gender: gender,
        status: status,
      );

      final userModel = await apiService.createUser(request);
      final user = userModel.toEntity();
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection. Please check your network.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        switch (statusCode) {
          case 400:
            return ServerFailure('Bad request: ${_extractErrorMessage(responseData)}');
          case 401:
            return const ServerFailure('Unauthorized. Invalid or expired token.');
          case 404:
            return const ServerFailure('Resource not found.');
          case 422:
            // Handle validation errors (e.g., duplicate email)
            final errorMessage = _extractErrorMessage(responseData);
            if (errorMessage.toLowerCase().contains('email')) {
              return const ValidationFailure('Email already exists or is invalid.');
            }
            return ValidationFailure(errorMessage);
          case 500:
          case 502:
          case 503:
            return const ServerFailure('Server error. Please try again later.');
          default:
            return ServerFailure('Request failed with status code: $statusCode');
        }
      
      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled.');
      
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Security certificate error.');
      
      case DioExceptionType.unknown:
        return NetworkFailure('Network error: ${error.message ?? "Unknown error"}');
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      // Try to extract error message from common response formats
      if (responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is String) return error;
        if (error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
      }
      // Handle array of errors (common in validation responses)
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
        if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }
    if (responseData is List && responseData.isNotEmpty) {
      final firstError = responseData.first;
      if (firstError is Map && firstError.containsKey('message')) {
        return firstError['message'].toString();
      }
      if (firstError is Map && firstError.containsKey('field')) {
        return '${firstError['field']}: ${firstError['message']}';
      }
    }
    return 'An error occurred';
  }
}

