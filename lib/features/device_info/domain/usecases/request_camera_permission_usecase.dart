import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/permission_status.dart';
import '../repositories/permission_repository.dart';

@injectable
class RequestCameraPermissionUseCase {
  final PermissionRepository repository;

  RequestCameraPermissionUseCase(this.repository);

  Future<Either<Failure, PermissionStatus>> call() async {
    return await repository.requestCameraPermission();
  }
}

