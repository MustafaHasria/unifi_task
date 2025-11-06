import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/create_user_request.dart';

@injectable
class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  Future<List<UserModel>> getUsersPaginated(int page, int perPage) async {
    try {
      final response = await _dio.get(
        ApiConstants.usersEndpoint,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> createUser(CreateUserRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.usersEndpoint,
        data: request.toJson(),
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}

