package com.mustafa.hasria.unifi_task

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val STORAGE_CHANNEL = "com.mustafa.hasria.unifi_task/storage"
    private val PERMISSIONS_CHANNEL = "com.mustafa.hasria.unifi_task/permissions"
    private val CAMERA_PERMISSION_REQUEST_CODE = 100

    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Storage channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STORAGE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStorageInfo" -> {
                    try {
                        val storageInfo = getStorageInfo()
                        result.success(storageInfo)
                    } catch (e: Exception) {
                        result.error(
                            "STORAGE_ERROR",
                            "Failed to get storage info: ${e.message}",
                            null
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Permissions channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PERMISSIONS_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestCameraPermission" -> {
                    requestCameraPermission(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getStorageInfo(): Map<String, Long> {
        val stat = StatFs(Environment.getDataDirectory().path)
        
        val blockSize = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            stat.blockSizeLong
        } else {
            stat.blockSize.toLong()
        }
        
        val totalBlocks = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            stat.blockCountLong
        } else {
            stat.blockCount.toLong()
        }
        
        val availableBlocks = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            stat.availableBlocksLong
        } else {
            stat.availableBlocks.toLong()
        }

        val totalSpace = totalBlocks * blockSize
        val freeSpace = availableBlocks * blockSize

        return mapOf(
            "totalSpace" to totalSpace,
            "freeSpace" to freeSpace
        )
    }

    private fun requestCameraPermission(result: MethodChannel.Result) {
        // Check current permission status
        when {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED -> {
                result.success("granted")
            }
            ActivityCompat.shouldShowRequestPermissionRationale(
                this,
                Manifest.permission.CAMERA
            ) -> {
                // Permission denied but not permanently
                permissionResult = result
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.CAMERA),
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            }
            else -> {
                // First time asking or permanently denied
                permissionResult = result
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.CAMERA),
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            val result = permissionResult ?: return
            
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                result.success("granted")
            } else {
                // Check if permanently denied
                val isPermanentlyDenied = !ActivityCompat.shouldShowRequestPermissionRationale(
                    this,
                    Manifest.permission.CAMERA
                )
                
                if (isPermanentlyDenied) {
                    result.success("permanentlyDenied")
                } else {
                    result.success("denied")
                }
            }
            
            permissionResult = null
        }
    }
}
