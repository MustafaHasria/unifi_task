import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers(int page, int perPage);
  Future<Either<Failure, User>> addUser({
    required String name,
    required String email,
    required String gender,
    required String status,
  });
}

