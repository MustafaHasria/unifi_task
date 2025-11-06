import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/permission_status.dart';

abstract class PermissionRepository {
  Future<Either<Failure, PermissionStatus>> requestCameraPermission();
}

