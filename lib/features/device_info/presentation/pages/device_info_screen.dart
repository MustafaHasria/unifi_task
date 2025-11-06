import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/permission_status.dart';
import '../bloc/device_info_bloc.dart';
import '../bloc/device_info_event.dart';
import '../bloc/device_info_state.dart';

class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeviceInfoBloc>()..add(const LoadStorageInfoEvent()),
      child: const _DeviceInfoScreenContent(),
    );
  }
}

class _DeviceInfoScreenContent extends StatelessWidget {
  const _DeviceInfoScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
      ),
      body: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
        builder: (context, state) {
          if (state is DeviceInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DeviceInfoError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DeviceInfoBloc>().add(
                              const LoadStorageInfoEvent(),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DeviceInfoLoaded || state is PermissionRequesting) {
            final loadedState = state is DeviceInfoLoaded
                ? state
                : (state as PermissionRequesting);
            
            final storageInfo = loadedState is DeviceInfoLoaded 
                ? loadedState.storageInfo 
                : null;
            final permissionStatus = loadedState is DeviceInfoLoaded
                ? loadedState.permissionStatus
                : PermissionStatus.notDetermined;
            final isRequestingPermission = state is PermissionRequesting;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Storage Info Card
                  if (storageInfo != null) ...[
                    _StorageInfoCard(storageInfo: storageInfo),
                    SizedBox(height: 16.h),
                  ],

                  // Camera Permission Card
                  _CameraPermissionCard(
                    permissionStatus: permissionStatus,
                    isRequesting: isRequestingPermission,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StorageInfoCard extends StatelessWidget {
  final dynamic storageInfo;

  const _StorageInfoCard({required this.storageInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 28.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Device Storage',
                  style: AppTextStyles.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Circular progress indicator
            Center(
              child: SizedBox(
                width: 180.w,
                height: 180.h,
                child: CustomPaint(
                  painter: _CircularProgressPainter(
                    percentage: storageInfo.usagePercentage,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${storageInfo.usagePercentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Used',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Storage details
            _StorageDetailRow(
              icon: Icons.check_circle,
              color: AppColors.success,
              label: 'Free Space',
              value: storageInfo.freeSpaceGB,
            ),
            SizedBox(height: 12.h),
            _StorageDetailRow(
              icon: Icons.sim_card,
              color: AppColors.info,
              label: 'Total Space',
              value: storageInfo.totalSpaceGB,
            ),
            SizedBox(height: 12.h),
            _StorageDetailRow(
              icon: Icons.folder,
              color: AppColors.warning,
              label: 'Used Space',
              value: storageInfo.usedSpaceGB,
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageDetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StorageDetailRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: color),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium,
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;

  _CircularProgressPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CameraPermissionCard extends StatelessWidget {
  final PermissionStatus permissionStatus;
  final bool isRequesting;

  const _CameraPermissionCard({
    required this.permissionStatus,
    required this.isRequesting,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 28.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Camera Permission',
                  style: AppTextStyles.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            _PermissionStatusRow(status: permissionStatus),
            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRequesting
                    ? null
                    : () {
                        context.read<DeviceInfoBloc>().add(
                              const RequestCameraPermissionEvent(),
                            );
                      },
                icon: isRequesting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.security),
                label: Text(
                  isRequesting ? 'Requesting...' : 'Request Permission',
                ),
              ),
            ),

            if (permissionStatus.isPermanentlyDenied) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Permission permanently denied. Please enable it from settings.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionStatusRow extends StatelessWidget {
  final PermissionStatus status;

  const _PermissionStatusRow({required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case PermissionStatus.granted:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Granted';
        break;
      case PermissionStatus.denied:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Denied';
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = AppColors.error;
        statusIcon = Icons.block;
        statusText = 'Permanently Denied';
        break;
      case PermissionStatus.notDetermined:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.help_outline;
        statusText = 'Not Determined';
        break;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                statusText,
                style: AppTextStyles.titleMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

