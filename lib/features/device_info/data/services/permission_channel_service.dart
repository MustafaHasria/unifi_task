import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/permission_status.dart';

@injectable
class PermissionChannelService {
  final MethodChannel _channel = const MethodChannel(
    AppConstants.permissionsChannelName,
  );

  Future<PermissionStatus> checkCameraPermission() async {
    try {
      final result = await _channel.invokeMethod<String>(
        AppConstants.checkCameraPermissionMethod,
      );

      if (result == null) {
        return PermissionStatus.notDetermined;
      }

      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to check camera permission',
        details: e.details,
      );
    }
  }

  Future<PermissionStatus> requestCameraPermission() async {
    try {
      final result = await _channel.invokeMethod<String>(
        AppConstants.requestCameraPermissionMethod,
      );

      if (result == null) {
        return PermissionStatus.denied;
      }

      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to request camera permission',
        details: e.details,
      );
    }
  }

  PermissionStatus _parsePermissionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return PermissionStatus.granted;
      case 'denied':
        return PermissionStatus.denied;
      case 'permanentlydenied':
        return PermissionStatus.permanentlyDenied;
      case 'notdetermined':
        return PermissionStatus.notDetermined;
      default:
        return PermissionStatus.denied;
    }
  }
}

