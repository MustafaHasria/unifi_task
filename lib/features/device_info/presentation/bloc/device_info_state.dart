import 'package:equatable/equatable.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/entities/storage_info.dart';

abstract class DeviceInfoState extends Equatable {
  const DeviceInfoState();

  @override
  List<Object?> get props => [];
}

class DeviceInfoInitial extends DeviceInfoState {
  const DeviceInfoInitial();
}

class DeviceInfoLoading extends DeviceInfoState {
  const DeviceInfoLoading();
}

class DeviceInfoLoaded extends DeviceInfoState {
  final StorageInfo? storageInfo;
  final PermissionStatus permissionStatus;

  const DeviceInfoLoaded({
    this.storageInfo,
    this.permissionStatus = PermissionStatus.notDetermined,
  });

  DeviceInfoLoaded copyWith({
    StorageInfo? storageInfo,
    PermissionStatus? permissionStatus,
  }) {
    return DeviceInfoLoaded(
      storageInfo: storageInfo ?? this.storageInfo,
      permissionStatus: permissionStatus ?? this.permissionStatus,
    );
  }

  @override
  List<Object?> get props => [storageInfo, permissionStatus];
}

class DeviceInfoError extends DeviceInfoState {
  final String message;

  const DeviceInfoError(this.message);

  @override
  List<Object?> get props => [message];
}

class PermissionRequesting extends DeviceInfoState {
  const PermissionRequesting();
}

