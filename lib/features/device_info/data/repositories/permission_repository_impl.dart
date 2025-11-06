import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/repositories/permission_repository.dart';
import '../services/permission_channel_service.dart';

@LazySingleton(as: PermissionRepository)
class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionChannelService permissionChannelService;

  PermissionRepositoryImpl(this.permissionChannelService);

  @override
  Future<Either<Failure, PermissionStatus>> checkCameraPermission() async {
    try {
      final status = await permissionChannelService.checkCameraPermission();
      return Right(status);
    } on PlatformException catch (e) {
      return Left(
        PlatformFailure(
          e.message ?? 'Failed to check camera permission from platform',
        ),
      );
    } catch (e) {
      return Left(PlatformFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PermissionStatus>> requestCameraPermission() async {
    try {
      final status = await permissionChannelService.requestCameraPermission();
      return Right(status);
    } on PlatformException catch (e) {
      return Left(
        PlatformFailure(
          e.message ?? 'Failed to request camera permission from platform',
        ),
      );
    } catch (e) {
      return Left(PlatformFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

