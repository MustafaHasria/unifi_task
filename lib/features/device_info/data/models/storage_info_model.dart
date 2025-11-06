import '../../domain/entities/storage_info.dart';

class StorageInfoModel {
  final double freeSpace;
  final double totalSpace;

  StorageInfoModel({
    required this.freeSpace,
    required this.totalSpace,
  });

  factory StorageInfoModel.fromPlatform(Map<Object?, Object?> map) {
    return StorageInfoModel(
      freeSpace: (map['freeSpace'] as num?)?.toDouble() ?? 0.0,
      totalSpace: (map['totalSpace'] as num?)?.toDouble() ?? 0.0,
    );
  }

  StorageInfo toEntity() {
    return StorageInfo(
      freeSpace: freeSpace,
      totalSpace: totalSpace,
    );
  }
}

