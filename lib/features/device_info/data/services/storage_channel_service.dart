import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/storage_info_model.dart';

@injectable
class StorageChannelService {
  final MethodChannel _channel = const MethodChannel(
    AppConstants.storageChannelName,
  );

  Future<StorageInfoModel> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        AppConstants.getStorageInfoMethod,
      );

      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'Storage info returned null',
        );
      }

      return StorageInfoModel.fromPlatform(result);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to get storage info',
        details: e.details,
      );
    }
  }
}

