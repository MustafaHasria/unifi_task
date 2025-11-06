import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@injectable
class AddUserUseCase {
  final UserRepository repository;

  AddUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String gender,
    required String status,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate required fields
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Name is required'));
    }

    if (gender.trim().isEmpty) {
      return const Left(ValidationFailure('Gender is required'));
    }

    if (status.trim().isEmpty) {
      return const Left(ValidationFailure('Status is required'));
    }

    return await repository.addUser(
      name: name.trim(),
      email: email.trim(),
      gender: gender,
      status: status,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

