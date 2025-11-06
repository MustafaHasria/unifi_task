// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/device_info/data/repositories/device_info_repository_impl.dart'
    as _i632;
import '../../features/device_info/data/repositories/permission_repository_impl.dart'
    as _i331;
import '../../features/device_info/data/services/permission_channel_service.dart'
    as _i134;
import '../../features/device_info/data/services/storage_channel_service.dart'
    as _i933;
import '../../features/device_info/domain/repositories/device_info_repository.dart'
    as _i65;
import '../../features/device_info/domain/repositories/permission_repository.dart'
    as _i842;
import '../../features/device_info/domain/usecases/check_camera_permission_usecase.dart'
    as _i488;
import '../../features/device_info/domain/usecases/get_storage_info_usecase.dart'
    as _i980;
import '../../features/device_info/domain/usecases/request_camera_permission_usecase.dart'
    as _i714;
import '../../features/device_info/presentation/bloc/device_info_bloc.dart'
    as _i62;
import '../../features/users/data/data_source/user_local_data_source.dart'
    as _i205;
import '../../features/users/data/repositories/user_repository_impl.dart'
    as _i465;
import '../../features/users/data/services/user_api_service.dart' as _i624;
import '../../features/users/domain/repositories/user_repository.dart' as _i658;
import '../../features/users/domain/usecases/add_user_usecase.dart' as _i511;
import '../../features/users/domain/usecases/get_users_usecase.dart' as _i499;
import '../../features/users/presentation/bloc/user_bloc.dart' as _i166;
import '../database/database_helper.dart' as _i64;
import '../network/dio_client.dart' as _i667;
import '../network/network_info.dart' as _i932;
import '../services/native_toast_service.dart' as _i722;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.factory<_i722.NativeToastService>(() => _i722.NativeToastService());
    gh.factory<_i134.PermissionChannelService>(
      () => _i134.PermissionChannelService(),
    );
    gh.factory<_i933.StorageChannelService>(
      () => _i933.StorageChannelService(),
    );
    gh.lazySingleton<_i895.Connectivity>(() => dioModule.connectivity);
    gh.lazySingleton<_i64.DatabaseHelper>(() => dioModule.databaseHelper);
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.factory<_i624.UserApiService>(
      () => _i624.UserApiService(gh<_i361.Dio>()),
    );
    gh.factory<_i205.UserLocalDataSource>(
      () => _i205.UserLocalDataSource(gh<_i64.DatabaseHelper>()),
    );
    gh.lazySingleton<_i65.DeviceInfoRepository>(
      () => _i632.DeviceInfoRepositoryImpl(gh<_i933.StorageChannelService>()),
    );
    gh.factory<_i980.GetStorageInfoUseCase>(
      () => _i980.GetStorageInfoUseCase(gh<_i65.DeviceInfoRepository>()),
    );
    gh.lazySingleton<_i842.PermissionRepository>(
      () =>
          _i331.PermissionRepositoryImpl(gh<_i134.PermissionChannelService>()),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i658.UserRepository>(
      () => _i465.UserRepositoryImpl(
        gh<_i624.UserApiService>(),
        gh<_i205.UserLocalDataSource>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.factory<_i499.GetUsersUseCase>(
      () => _i499.GetUsersUseCase(gh<_i658.UserRepository>()),
    );
    gh.factory<_i511.AddUserUseCase>(
      () => _i511.AddUserUseCase(gh<_i658.UserRepository>()),
    );
    gh.factory<_i714.RequestCameraPermissionUseCase>(
      () => _i714.RequestCameraPermissionUseCase(
        gh<_i842.PermissionRepository>(),
      ),
    );
    gh.factory<_i488.CheckCameraPermissionUseCase>(
      () =>
          _i488.CheckCameraPermissionUseCase(gh<_i842.PermissionRepository>()),
    );
    gh.factory<_i62.DeviceInfoBloc>(
      () => _i62.DeviceInfoBloc(
        getStorageInfoUseCase: gh<_i980.GetStorageInfoUseCase>(),
        checkCameraPermissionUseCase: gh<_i488.CheckCameraPermissionUseCase>(),
        requestCameraPermissionUseCase:
            gh<_i714.RequestCameraPermissionUseCase>(),
      ),
    );
    gh.factory<_i166.UserBloc>(
      () => _i166.UserBloc(
        getUsersUseCase: gh<_i499.GetUsersUseCase>(),
        addUserUseCase: gh<_i511.AddUserUseCase>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i667.DioModule {}
