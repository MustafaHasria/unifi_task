import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/usecases/check_camera_permission_usecase.dart';
import '../../domain/usecases/get_storage_info_usecase.dart';
import '../../domain/usecases/request_camera_permission_usecase.dart';
import 'device_info_event.dart';
import 'device_info_state.dart';

@injectable
class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final GetStorageInfoUseCase getStorageInfoUseCase;
  final CheckCameraPermissionUseCase checkCameraPermissionUseCase;
  final RequestCameraPermissionUseCase requestCameraPermissionUseCase;

  DeviceInfoBloc({
    required this.getStorageInfoUseCase,
    required this.checkCameraPermissionUseCase,
    required this.requestCameraPermissionUseCase,
  }) : super(const DeviceInfoInitial()) {
    on<LoadStorageInfoEvent>(_onLoadStorageInfo);
    on<CheckCameraPermissionEvent>(_onCheckCameraPermission);
    on<RequestCameraPermissionEvent>(_onRequestCameraPermission);
  }

  Future<void> _onLoadStorageInfo(LoadStorageInfoEvent event, Emitter<DeviceInfoState> emit) async {
    emit(const DeviceInfoLoading());

    final storageResult = await getStorageInfoUseCase();
    final permissionResult = await checkCameraPermissionUseCase();

    storageResult.fold((failure) => emit(DeviceInfoError(failure.message)), (storageInfo) {
      final permissionStatus = permissionResult.fold((_) => PermissionStatus.notDetermined, (status) => status);
      emit(DeviceInfoLoaded(storageInfo: storageInfo, permissionStatus: permissionStatus));
    });
  }

  Future<void> _onCheckCameraPermission(CheckCameraPermissionEvent event, Emitter<DeviceInfoState> emit) async {
    if (state is DeviceInfoLoaded) {
      final currentState = state as DeviceInfoLoaded;

      final result = await checkCameraPermissionUseCase();

      result.fold(
        (failure) {
          // Keep current state on error
          emit(currentState);
        },
        (permissionStatus) {
          emit(currentState.copyWith(permissionStatus: permissionStatus));
        },
      );
    }
  }

  Future<void> _onRequestCameraPermission(RequestCameraPermissionEvent event, Emitter<DeviceInfoState> emit) async {
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
