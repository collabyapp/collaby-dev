import 'dart:io';
import 'package:collaby_app/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );

  /// Download file from URL and save to device
  static Future<void> downloadFile({
    required String url,
    String? fileName,
    Function(int, int)? onProgress,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        onError?.call('Storage permission denied');
        Utils.snackBar(
          'Permission Denied',
          'Please allow storage permission to download files',
          // backgroundColor: Colors.red.withOpacity(0.1),
          // colorText: Colors.red.shade700,
          // icon: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          // snackPosition: SnackPosition.TOP,
          // borderRadius: 12,
          // margin: EdgeInsets.all(16),
        );
        return;
      }

      // Get file name from URL if not provided
      fileName ??= _getFileNameFromUrl(url);

      // Get download directory
      final savePath = await _getDownloadPath(fileName);

      // Show download started snackbar
      // Utils.snackBar(
      //   'Download Started',
      //   'Downloading $fileName...',
      //   backgroundColor: Colors.blue.withOpacity(0.1),
      //   colorText: Colors.blue.shade700,
      //   icon: Icon(Icons.download_rounded, color: Colors.blue.shade700),
      //   snackPosition: SnackPosition.TOP,
      //   borderRadius: 12,
      //   margin: EdgeInsets.all(16),
      //   duration: Duration(seconds: 2),
      // );

      // Download file with progress tracking
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download progress: $progress%');
            onProgress?.call(received, total);
          }
        },
      );

      // Success
      debugPrint('âœ… File downloaded successfully: $savePath');
      onSuccess?.call();

      // Show success snackbar
      // Utils.snackBar(
      //   'Download Complete',
      //   'File saved to Downloads folder',
      //   backgroundColor: Colors.green.withOpacity(0.1),
      //   colorText: Colors.green.shade700,
      //   icon: Icon(Icons.check_circle_rounded, color: Colors.green.shade700),
      //   snackPosition: SnackPosition.TOP,
      //   borderRadius: 12,
      //   margin: EdgeInsets.all(16),
      //   duration: Duration(seconds: 3),
      // );
    } catch (e) {
      debugPrint('âŒ Download error: $e');
      onError?.call(e.toString());

      Utils.snackBar(
        'Download Failed',
        'Failed to download file. Please try again.',
        // backgroundColor: Colors.red.withOpacity(0.1),
        // colorText: Colors.red.shade700,
        // icon: Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
        // snackPosition: SnackPosition.TOP,
        // borderRadius: 12,
        // margin: EdgeInsets.all(16),
        // duration: Duration(seconds: 3),
      );
    }
  }

  /// Download file with loading dialog showing progress
  static Future<void> downloadFileWithDialog({
    required String url,
    required BuildContext context,
    String? fileName,
  }) async {
    Get.dialog(
      _DownloadProgressDialog(url: url, fileName: fileName),
      barrierDismissible: false,
    );
  }

  /// Request storage permission
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        return true;
      } else if (androidInfo >= 30) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        return status.isGranted;
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return true;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      return 33;
    }
    return 0;
  }

  /// Get download path based on platform
  static Future<String> _getDownloadPath(String fileName) async {
    String directory;

    if (Platform.isAndroid) {
      directory = '/storage/emulated/0/Download';

      if (!await Directory(directory).exists()) {
        final dir = await getExternalStorageDirectory();
        directory = dir!.path;
      }
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      directory = dir.path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      directory = dir.path;
    }

    final downloadDir = Directory(directory);
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    // Handle duplicate filenames
    String finalPath = '$directory/$fileName';
    int counter = 1;
    while (await File(finalPath).exists()) {
      final nameParts = fileName.split('.');
      if (nameParts.length > 1) {
        final name = nameParts.sublist(0, nameParts.length - 1).join('.');
        final ext = nameParts.last;
        finalPath = '$directory/$name($counter).$ext';
      } else {
        finalPath = '$directory/$fileName($counter)';
      }
      counter++;
    }

    return finalPath;
  }

  /// Extract file name from URL
  static String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'download_${DateTime.now().millisecondsSinceEpoch}';

      if (!fileName.contains('.')) {
        fileName = 'download_${DateTime.now().millisecondsSinceEpoch}';
      }

      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      return fileName;
    } catch (e) {
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get file extension from URL
  static String getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.contains('.')) {
        return path.substring(path.lastIndexOf('.') + 1).toLowerCase();
      }
    } catch (e) {
      debugPrint('Error getting file extension: $e');
    }
    return 'file';
  }

  /// Get file icon based on extension
  static IconData getFileIcon(String url) {
    final extension = getFileExtension(url);

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image_rounded;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
      case 'wmv':
        return Icons.video_file_rounded;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return Icons.audio_file_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  /// Format bytes to human readable format
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Download Controller with GetX
class DownloadController extends GetxController {
  var progress = 0.0.obs;
  var downloadedSize = '0 B'.obs;
  var totalSize = '0 B'.obs;
  var isDownloading = true.obs;
  var errorMessage = Rx<String?>(null);

  void updateProgress(int received, int total) {
    progress.value = received / total;
    downloadedSize.value = DownloadService.formatBytes(received);
    totalSize.value = DownloadService.formatBytes(total);
  }

  void setSuccess() {
    isDownloading.value = false;
    progress.value = 1.0;
  }

  void setError(String error) {
    isDownloading.value = false;
    errorMessage.value = error;
  }
}

/// Download Progress Dialog Widget with GetX
class _DownloadProgressDialog extends StatelessWidget {
  final String url;
  final String? fileName;

  const _DownloadProgressDialog({required this.url, this.fileName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DownloadController());

    // Start download
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDownload(controller);
    });

    return WillPopScope(
      onWillPop: () async => !controller.isDownloading.value,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon Container
                Obx(
                  () => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: controller.errorMessage.value != null
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : (controller.progress.value >= 1.0
                                  ? [
                                      Colors.green.shade400,
                                      Colors.green.shade600,
                                    ]
                                  : [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (controller.errorMessage.value != null
                                      ? Colors.red
                                      : (controller.progress.value >= 1.0
                                            ? Colors.green
                                            : Color(0xFF6366F1)))
                                  .withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.errorMessage.value != null
                          ? Icons.error_outline_rounded
                          : (controller.progress.value >= 1.0
                                ? Icons.check_circle_outline_rounded
                                : Icons.cloud_download_rounded),
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Title with Animation
                Obx(
                  () => AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      controller.errorMessage.value != null
                          ? 'Download Failed'
                          : (controller.progress.value >= 1.0
                                ? 'Download Complete!'
                                : 'Downloading...'),
                      key: ValueKey(
                        controller.errorMessage.value != null
                            ? 'error'
                            : (controller.progress.value >= 1.0
                                  ? 'complete'
                                  : 'downloading'),
                      ),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // File name with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      DownloadService.getFileIcon(url),
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        fileName ?? 'File',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                Obx(
                  () => controller.errorMessage.value == null
                      ? Column(
                          children: [
                            SizedBox(height: 28),

                            // Circular Progress Indicator
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: controller.progress.value,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${(controller.progress.value * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Downloaded',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 24),

                            // Size info with styled container
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Downloaded',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        controller.downloadedSize.value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.grey.shade300,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Size',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        controller.totalSize.value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.errorMessage.value!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                ),

                // Cancel button
                Obx(
                  () => controller.isDownloading.value
                      ? Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                              Get.delete<DownloadController>();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startDownload(DownloadController controller) async {
    await DownloadService.downloadFile(
      url: url,
      fileName: fileName,
      onProgress: (received, total) {
        controller.updateProgress(received, total);
      },
      onSuccess: () {
        controller.setSuccess();
        Future.delayed(Duration(milliseconds: 800), () {
          Get.back();
          Get.delete<DownloadController>();
        });
      },
      onError: (error) {
        controller.setError(error);
        Future.delayed(Duration(seconds: 2), () {
          Get.back();
          Get.delete<DownloadController>();
        });
      },
    );
  }
}
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Response;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DownloadService {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: Duration(seconds: 30),
//       receiveTimeout: Duration(seconds: 30),
//     ),
//   );

//   /// Download file from URL and save to device
//   static Future<void> downloadFile({
//     required String url,
//     String? fileName,
//     Function(int, int)? onProgress,
//     VoidCallback? onSuccess,
//     Function(String)? onError,
//   }) async {
//     try {
//       // Request storage permission
//       final hasPermission = await _requestStoragePermission();
//       if (!hasPermission) {
//         onError?.call('Storage permission denied');
//         Utils.snackBar(
//           'Permission Denied',
//           'Please allow storage permission to download files',
//         );
//         return;
//       }

//       // Get file name from URL if not provided
//       fileName ??= _getFileNameFromUrl(url);

//       // Get download directory
//       final savePath = await _getDownloadPath(fileName);

//       // Show download started snackbar
//       Utils.snackBar('Download Started', 'Downloading $fileName...');

//       // Download file with progress tracking
//       await _dio.download(
//         url,
//         savePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             final progress = (received / total * 100).toStringAsFixed(0);
//             debugPrint('Download progress: $progress%');
//             onProgress?.call(received, total);
//           }
//         },
//       );

//       // Success
//       debugPrint('âœ… File downloaded successfully: $savePath');
//       onSuccess?.call();

//       // Show success snackbar
//       Utils.snackBar(
//         'Download Complete',
//         'File saved to Downloads folder',
//         backgroundColor: Colors.green.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//         snackPosition: SnackPosition.BOTTOM,
//         icon: Icon(Icons.check_circle, color: Colors.white),
//       );
//     } catch (e) {
//       debugPrint('âŒ Download error: $e');
//       onError?.call(e.toString());

//       Utils.snackBar(
//         'Download Failed',
//         'Failed to download file. Please try again.',
//       );
//     }
//   }

//   /// Download file with loading dialog showing progress
//   static Future<void> downloadFileWithDialog({
//     required String url,
//     required BuildContext context,
//     String? fileName,
//   }) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) =>
//           _DownloadProgressDialog(url: url, fileName: fileName),
//     );
//   }

//   /// Request storage permission
//   static Future<bool> _requestStoragePermission() async {
//     if (Platform.isAndroid) {
//       // Check Android version
//       final androidInfo = await _getAndroidVersion();

//       if (androidInfo >= 33) {
//         // Android 13+ doesn't need storage permission for downloads
//         return true;
//       } else if (androidInfo >= 30) {
//         // Android 11-12: Check MANAGE_EXTERNAL_STORAGE
//         var status = await Permission.manageExternalStorage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.request();
//         }
//         return status.isGranted;
//       } else {
//         // Android 10 and below: Use regular storage permission
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.storage.request();
//         }
//         return status.isGranted;
//       }
//     }
//     return true; // iOS doesn't need permission for app directory
//   }

//   /// Get Android SDK version
//   static Future<int> _getAndroidVersion() async {
//     if (Platform.isAndroid) {
//       // This is a simplified check, you might need to use device_info_plus
//       return 33; // Default to latest for safety
//     }
//     return 0;
//   }

//   /// Get download path based on platform
//   static Future<String> _getDownloadPath(String fileName) async {
//     String directory;

//     if (Platform.isAndroid) {
//       // Use /storage/emulated/0/Download for Android
//       directory = '/storage/emulated/0/Download';

//       // Fallback to external storage if primary doesn't exist
//       if (!await Directory(directory).exists()) {
//         final dir = await getExternalStorageDirectory();
//         directory = dir!.path;
//       }
//     } else if (Platform.isIOS) {
//       // Use app documents directory for iOS
//       final dir = await getApplicationDocumentsDirectory();
//       directory = dir.path;
//     } else {
//       // Fallback for other platforms
//       final dir = await getApplicationDocumentsDirectory();
//       directory = dir.path;
//     }

//     // Create directory if it doesn't exist
//     final downloadDir = Directory(directory);
//     if (!await downloadDir.exists()) {
//       await downloadDir.create(recursive: true);
//     }

//     // Handle duplicate filenames
//     String finalPath = '$directory/$fileName';
//     int counter = 1;
//     while (await File(finalPath).exists()) {
//       final nameParts = fileName.split('.');
//       if (nameParts.length > 1) {
//         final name = nameParts.sublist(0, nameParts.length - 1).join('.');
//         final ext = nameParts.last;
//         finalPath = '$directory/$name($counter).$ext';
//       } else {
//         finalPath = '$directory/$fileName($counter)';
//       }
//       counter++;
//     }

//     return finalPath;
//   }

//   /// Extract file name from URL
//   static String _getFileNameFromUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       String fileName = uri.pathSegments.isNotEmpty
//           ? uri.pathSegments.last
//           : 'download_${DateTime.now().millisecondsSinceEpoch}';

//       // If filename doesn't have extension, add a generic one
//       if (!fileName.contains('.')) {
//         fileName = 'download_${DateTime.now().millisecondsSinceEpoch}';
//       }

//       // Clean the filename
//       fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

//       return fileName;
//     } catch (e) {
//       return 'download_${DateTime.now().millisecondsSinceEpoch}';
//     }
//   }

//   /// Get file extension from URL
//   static String getFileExtension(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final path = uri.path;
//       if (path.contains('.')) {
//         return path.substring(path.lastIndexOf('.') + 1).toLowerCase();
//       }
//     } catch (e) {
//       debugPrint('Error getting file extension: $e');
//     }
//     return 'file';
//   }

//   /// Get file icon based on extension
//   static IconData getFileIcon(String url) {
//     final extension = getFileExtension(url);

//     switch (extension) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'doc':
//       case 'docx':
//         return Icons.description;
//       case 'xls':
//       case 'xlsx':
//         return Icons.table_chart;
//       case 'ppt':
//       case 'pptx':
//         return Icons.slideshow;
//       case 'png':
//       case 'jpg':
//       case 'jpeg':
//       case 'gif':
//       case 'bmp':
//       case 'webp':
//         return Icons.image;
//       case 'mp4':
//       case 'avi':
//       case 'mov':
//       case 'mkv':
//       case 'wmv':
//         return Icons.video_file;
//       case 'mp3':
//       case 'wav':
//       case 'aac':
//       case 'flac':
//         return Icons.audio_file;
//       case 'zip':
//       case 'rar':
//       case '7z':
//         return Icons.folder_zip;
//       case 'txt':
//         return Icons.text_snippet;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }

//   /// Format bytes to human readable format
//   static String formatBytes(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) {
//       return '${(bytes / 1024).toStringAsFixed(2)} KB';
//     }
//     if (bytes < 1024 * 1024 * 1024) {
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
//     }
//     return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
//   }
// }

// /// Download Progress Dialog Widget
// class _DownloadProgressDialog extends StatefulWidget {
//   final String url;
//   final String? fileName;

//   const _DownloadProgressDialog({required this.url, this.fileName});

//   @override
//   State<_DownloadProgressDialog> createState() =>
//       _DownloadProgressDialogState();
// }

// class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
//   double _progress = 0.0;
//   String _downloadedSize = '0 B';
//   String _totalSize = '0 B';
//   bool _isDownloading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _startDownload();
//   }

//   Future<void> _startDownload() async {
//     await DownloadService.downloadFile(
//       url: widget.url,
//       fileName: widget.fileName,
//       onProgress: (received, total) {
//         if (mounted) {
//           setState(() {
//             _progress = received / total;
//             _downloadedSize = DownloadService.formatBytes(received);
//             _totalSize = DownloadService.formatBytes(total);
//           });
//         }
//       },
//       onSuccess: () {
//         if (mounted) {
//           setState(() {
//             _isDownloading = false;
//             _progress = 1.0;
//           });
//           Future.delayed(Duration(milliseconds: 500), () {
//             if (mounted) {
//               Navigator.of(context).pop();
//             }
//           });
//         }
//       },
//       onError: (error) {
//         if (mounted) {
//           setState(() {
//             _isDownloading = false;
//             _errorMessage = error;
//           });
//           Future.delayed(Duration(seconds: 2), () {
//             if (mounted) {
//               Navigator.of(context).pop();
//             }
//           });
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => !_isDownloading,
//       child: Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icon
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: _errorMessage != null
//                       ? Colors.red.withOpacity(0.1)
//                       : Color(0xFF6366F1).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _errorMessage != null
//                       ? Icons.error_outline
//                       : (_progress >= 1.0
//                             ? Icons.check_circle_outline
//                             : Icons.download),
//                   size: 48,
//                   color: _errorMessage != null
//                       ? Colors.red
//                       : (_progress >= 1.0 ? Colors.green : Color(0xFF6366F1)),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Title
//               Text(
//                 _errorMessage != null
//                     ? 'Download Failed'
//                     : (_progress >= 1.0
//                           ? 'Download Complete!'
//                           : 'Downloading...'),
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),

//               // File name
//               Text(
//                 widget.fileName ?? 'File',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),

//               if (_errorMessage == null) ...[
//                 SizedBox(height: 24),

//                 // Progress bar
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: _progress,
//                     backgroundColor: Colors.grey[200],
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Color(0xFF6366F1),
//                     ),
//                     minHeight: 10,
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // Size info
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '$_downloadedSize / $_totalSize',
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                     ),
//                     Text(
//                       '${(_progress * 100).toStringAsFixed(1)}%',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6366F1),
//                       ),
//                     ),
//                   ],
//                 ),
//               ] else ...[
//                 SizedBox(height: 16),
//                 Text(
//                   _errorMessage!,
//                   style: TextStyle(fontSize: 12, color: Colors.red),
//                   textAlign: TextAlign.center,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],

//               // Cancel button (only show while downloading)
//               if (_isDownloading) ...[
//                 SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



