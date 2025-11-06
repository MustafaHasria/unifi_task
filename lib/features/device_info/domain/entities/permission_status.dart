enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  notDetermined;

  bool get isGranted => this == PermissionStatus.granted;
  bool get isDenied => this == PermissionStatus.denied;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
}

