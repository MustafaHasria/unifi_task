import 'package:equatable/equatable.dart';

abstract class DeviceInfoEvent extends Equatable {
  const DeviceInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadStorageInfoEvent extends DeviceInfoEvent {
  const LoadStorageInfoEvent();
}

class CheckCameraPermissionEvent extends DeviceInfoEvent {
  const CheckCameraPermissionEvent();
}

class RequestCameraPermissionEvent extends DeviceInfoEvent {
  const RequestCameraPermissionEvent();
}

