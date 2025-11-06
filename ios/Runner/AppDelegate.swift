import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let STORAGE_CHANNEL = "com.mustafa.hasria.unifi_task/storage"
  private let PERMISSIONS_CHANNEL = "com.mustafa.hasria.unifi_task/permissions"
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Storage channel
    let storageChannel = FlutterMethodChannel(
      name: STORAGE_CHANNEL,
      binaryMessenger: controller.binaryMessenger
    )
    storageChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "getStorageInfo":
        self.getStorageInfo(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Permissions channel
    let permissionsChannel = FlutterMethodChannel(
      name: PERMISSIONS_CHANNEL,
      binaryMessenger: controller.binaryMessenger
    )
    permissionsChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "requestCameraPermission":
        self.requestCameraPermission(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getStorageInfo(result: @escaping FlutterResult) {
    do {
      let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
      let values = try fileURL.resourceValues(forKeys: [
        .volumeTotalCapacityKey,
        .volumeAvailableCapacityKey
      ])
      
      guard let totalSpace = values.volumeTotalCapacity,
            let freeSpace = values.volumeAvailableCapacity else {
        result(FlutterError(
          code: "STORAGE_ERROR",
          message: "Failed to get storage values",
          details: nil
        ))
        return
      }
      
      let storageInfo: [String: Int64] = [
        "totalSpace": Int64(totalSpace),
        "freeSpace": Int64(freeSpace)
      ]
      
      result(storageInfo)
    } catch {
      result(FlutterError(
        code: "STORAGE_ERROR",
        message: "Failed to get storage info: \(error.localizedDescription)",
        details: nil
      ))
    }
  }
  
  private func requestCameraPermission(result: @escaping FlutterResult) {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
      result("granted")
      
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
          if granted {
            result("granted")
          } else {
            result("denied")
          }
        }
      }
      
    case .denied:
      result("denied")
      
    case .restricted:
      result("denied")
      
    @unknown default:
      result("denied")
    }
  }
}
