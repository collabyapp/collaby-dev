import 'dart:io';

class VideoUpload {
  final File file;
  final double progress;
  final String? thumbnailPath;
  final String? uploadedUrl;
  final String fileName;
  final int fileSize;
  final String fileType;

  VideoUpload({
    required this.file,
    required this.progress,
    this.thumbnailPath,
    this.uploadedUrl,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });

  VideoUpload copyWith({
    File? file,
    double? progress,
    String? thumbnailPath,
    String? uploadedUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
  }) {
    return VideoUpload(
      file: file ?? this.file,
      progress: progress ?? this.progress,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
    );
  }
}
