import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/storage_info.dart';
import '../repositories/device_info_repository.dart';

@injectable
class GetStorageInfoUseCase {
  final DeviceInfoRepository repository;

  GetStorageInfoUseCase(this.repository);

  Future<Either<Failure, StorageInfo>> call() async {
    return await repository.getStorageInfo();
  }
}

