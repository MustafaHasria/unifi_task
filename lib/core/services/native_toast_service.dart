import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@injectable
class NativeToastService {
  final MethodChannel _channel = const MethodChannel(
    'com.mustafa.hasria.unifi_task/toast',
  );

  Future<void> showToast({
    required String message,
    bool isLong = false,
  }) async {
    try {
      await _channel.invokeMethod('showToast', {
        'message': message,
        'duration': isLong ? 'long' : 'short',
      });
    } on PlatformException catch (e) {
      // Fallback silently if native toast fails
      print('Failed to show native toast: ${e.message}');
    }
  }

  Future<void> showSuccess(String message) async {
    await showToast(message: '✅ $message');
  }

  Future<void> showError(String message) async {
    await showToast(message: '❌ $message', isLong: true);
  }

  Future<void> showInfo(String message) async {
    await showToast(message: 'ℹ️ $message');
  }

  Future<void> showWarning(String message) async {
    await showToast(message: '⚠️ $message', isLong: true);
  }
}

