import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_storage_info_usecase.dart';
import '../../domain/usecases/request_camera_permission_usecase.dart';
import 'device_info_event.dart';
import 'device_info_state.dart';

@injectable
class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final GetStorageInfoUseCase getStorageInfoUseCase;
  final RequestCameraPermissionUseCase requestCameraPermissionUseCase;

  DeviceInfoBloc({
    required this.getStorageInfoUseCase,
    required this.requestCameraPermissionUseCase,
  }) : super(const DeviceInfoInitial()) {
    on<LoadStorageInfoEvent>(_onLoadStorageInfo);
    on<RequestCameraPermissionEvent>(_onRequestCameraPermission);
  }

  Future<void> _onLoadStorageInfo(
    LoadStorageInfoEvent event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(const DeviceInfoLoading());

    final result = await getStorageInfoUseCase();

    result.fold(
      (failure) => emit(DeviceInfoError(failure.message)),
      (storageInfo) => emit(DeviceInfoLoaded(storageInfo: storageInfo)),
    );
  }

  Future<void> _onRequestCameraPermission(
    RequestCameraPermissionEvent event,
    Emitter<DeviceInfoState> emit,
  ) async {
    if (state is DeviceInfoLoaded) {
      final currentState = state as DeviceInfoLoaded;
      emit(const PermissionRequesting());

      final result = await requestCameraPermissionUseCase();

      result.fold(
        (failure) {
          emit(currentState);
        },
        (permissionStatus) {
          emit(currentState.copyWith(permissionStatus: permissionStatus));
        },
      );
    }
  }
}

