import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_source/user_local_data_source.dart';
import '../models/create_user_request.dart';
import '../services/user_api_service.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserApiService apiService;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl(
    this.apiService,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, List<User>>> getUsers(int page, int perPage) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      // Online: Fetch from API and cache
      try {
        final userModels = await apiService.getUsersPaginated(page, perPage);
        
        // Cache only the first page
        if (page == 1) {
          await localDataSource.cacheUsers(userModels);
        }
        
        final users = userModels.map((model) => model.toEntity()).toList();
        return Right(users);
      } on DioException catch (e) {
        // If API fails but we're online, try to return cached data
        return await _getCachedUsersOrError(e);
      } catch (e) {
        return await _getCachedUsersOrError(null);
      }
    } else {
      // Offline: Load from cache
      try {
        final hasCachedData = await localDataSource.hasCachedData();
        
        if (!hasCachedData) {
          return const Left(
            NetworkFailure('No internet connection and no cached data available'),
          );
        }
        
        final cachedModels = await localDataSource.getCachedUsers();
        final users = cachedModels.map((model) => model.toEntity()).toList();
        
        return Right(users);
      } catch (e) {
        return Left(CacheFailure('Failed to load cached data: ${e.toString()}'));
      }
    }
  }

  Future<Either<Failure, List<User>>> _getCachedUsersOrError(dynamic error) async {
    try {
      final hasCachedData = await localDataSource.hasCachedData();
      
      if (hasCachedData) {
        final cachedModels = await localDataSource.getCachedUsers();
        final users = cachedModels.map((model) => model.toEntity()).toList();
        return Right(users);
      }
    } catch (_) {
      // Fall through to error handling
    }
    
    if (error is DioException) {
      return Left(_handleDioError(error));
    }
    return Left(ServerFailure('Unexpected error: ${error.toString()}'));
  }

  @override
  Future<Either<Failure, User>> addUser({
    required String name,
    required String email,
    required String gender,
    required String status,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return const Left(
        NetworkFailure('Cannot add user while offline. Please check your internet connection.'),
      );
    }

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

