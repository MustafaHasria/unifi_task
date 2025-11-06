import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/permission_status.dart';
import '../repositories/permission_repository.dart';

@injectable
class CheckCameraPermissionUseCase {
  final PermissionRepository repository;

  CheckCameraPermissionUseCase(this.repository);

  Future<Either<Failure, PermissionStatus>> call() async {
    return await repository.checkCameraPermission();
  }
}

