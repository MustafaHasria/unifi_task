import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/storage_info.dart';

abstract class DeviceInfoRepository {
  Future<Either<Failure, StorageInfo>> getStorageInfo();
}

