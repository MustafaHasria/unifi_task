import 'package:equatable/equatable.dart';

class StorageInfo extends Equatable {
  final double freeSpace;
  final double totalSpace;

  const StorageInfo({
    required this.freeSpace,
    required this.totalSpace,
  });

  double get usedSpace => totalSpace - freeSpace;
  double get usagePercentage => (usedSpace / totalSpace) * 100;

  String get freeSpaceGB => _formatBytes(freeSpace);
  String get totalSpaceGB => _formatBytes(totalSpace);
  String get usedSpaceGB => _formatBytes(usedSpace);

  String _formatBytes(double bytes) {
    final gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(2)} GB';
  }

  @override
  List<Object?> get props => [freeSpace, totalSpace];
}

