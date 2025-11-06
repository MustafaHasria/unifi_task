import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/storage_info.dart';
import '../../domain/repositories/device_info_repository.dart';
import '../services/storage_channel_service.dart';

@LazySingleton(as: DeviceInfoRepository)
class DeviceInfoRepositoryImpl implements DeviceInfoRepository {
  final StorageChannelService storageChannelService;

  DeviceInfoRepositoryImpl(this.storageChannelService);

  @override
  Future<Either<Failure, StorageInfo>> getStorageInfo() async {
    try {
      final model = await storageChannelService.getStorageInfo();
      return Right(model.toEntity());
    } on PlatformException catch (e) {
      return Left(
        PlatformFailure(
          e.message ?? 'Failed to get storage information from platform',
        ),
      );
    } catch (e) {
      return Left(PlatformFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

