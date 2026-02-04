import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collaby_app/data/network/base_api_services.dart';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../app_exceptions.dart';


class UploadResult {
  final String url;
  final String? thumbnailUrl;
  final String? filename;
  final int? size;
  final String? mimetype;
  final String? storageType;

  UploadResult({
    required this.url,
    this.thumbnailUrl,
    this.filename,
    this.size,
    this.mimetype,
    this.storageType,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?) ?? {};
    return UploadResult(
      url: (data['url'] ?? json['url'] ?? '') as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      filename: data['filename'] as String?,
      size: (data['size'] is int) ? data['size'] as int : null,
      mimetype: data['mimetype'] as String?,
      storageType: data['storageType'] as String?,
    );
  }
}


class NetworkApiServices extends BaseApiServices {
  Future<dynamic> getApi(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters, // Optional query parameters
  }) async {
    Uri uri = Uri.parse(url); // base URL
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters,
      ); // Append query params if they exist
    }

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: 60));
      return returnResponse(response);
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  @override
  Future<dynamic> postApi(
    dynamic data,
    String url, {
    Map<String, String>? headers,
    bool sendJson = true,
  }) async {
    if (kDebugMode) {
      print('🌐 POST URL: $url');
      print('📋 Headers: $headers');
      print('📦 Raw Data: $data');
      print('📦 Data Type: ${data.runtimeType}');
      if (sendJson) {
        print('📦 JSON Data: ${jsonEncode(data)}');
      }
    }

    dynamic responseJson;
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers:
                headers ??
                {
                  'Content-Type': sendJson
                      ? 'application/json'
                      : 'application/x-www-form-urlencoded',
                },
            body: sendJson ? jsonEncode(data) : data,
          )
          .timeout(const Duration(seconds: 60));

      if (kDebugMode) {
        print('📈 Response Status: ${response.statusCode}');
        print('📈 Response Headers: ${response.headers}');
        print('📈 Response Body: ${response.body}');
      }

      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeOut {
      throw RequestTimeOut('');
    }

    if (kDebugMode) print('✅ Final Response: $responseJson');
    return responseJson;
  }

  /// PUT request method for updating resources
  Future<dynamic> putApi(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    bool sendJson = true,
  }) async {
    if (kDebugMode) {
      print('🌐 PUT URL: $url');
      print('📋 Headers: $headers');
      print('📦 Raw Data: $data');
      print('📦 Data Type: ${data.runtimeType}');
      if (sendJson && data != null) {
        print('📦 JSON Data: ${jsonEncode(data)}');
      }
    }

    dynamic responseJson;
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers:
                headers ??
                {
                  'Content-Type': sendJson
                      ? 'application/json'
                      : 'application/x-www-form-urlencoded',
                },
            body: data != null ? (sendJson ? jsonEncode(data) : data) : null,
          )
          .timeout(const Duration(seconds: 60));

      if (kDebugMode) {
        print('📈 Response Status: ${response.statusCode}');
        print('📈 Response Headers: ${response.headers}');
        print('📈 Response Body: ${response.body}');
      }

      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('No Internet Connection');
    } on TimeoutException {
      throw RequestTimeOut('Request timed out');
    } catch (e) {
      if (kDebugMode) print('❌ PUT Error: $e');
      rethrow;
    }

    if (kDebugMode) print('✅ Final Response: $responseJson');
    return responseJson;
  }

  // Create the PATCH request function
  Future<Map<String, dynamic>> patchApi(
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      if (kDebugMode) {
        print('🌐 PATCH URL: $url');
        print('📋 Headers: $headers');
        print('📦 Raw Data: $data');
        print('📦 Data Type: ${data.runtimeType}');

        print('📦 JSON Data: ${jsonEncode(data)}');
      }

      // Make the PATCH request
      final response = await http
          .patch(
            Uri.parse(url), // Use Uri.parse for the URL
            headers:
                headers ??
                {
                  'Content-Type': 'application/json',
                  // ...?headers,
                }, // Default headers
            body: jsonEncode(data), // Send data as JSON
          )
          .timeout(const Duration(seconds: 60)); // Timeout for the request
      if (kDebugMode) {
        print('📈 Response Status: ${response.statusCode}');
        print('📈 Response Headers: ${response.headers}');
        print('📈 Response Body: ${response.body}');
      }

      if (kDebugMode) print('✅ Final Response: $response');
      // Process the response
      return returnResponse(response);
    } catch (e) {
      if (kDebugMode) print('❌ PUT Error: $e');
      return {
        'statusCode': 500,
        'message': 'Network Error',
        'error': e.toString(),
      };
    }
  }

  Future<dynamic> deleteApi(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 60));

      return returnResponse(response);
    } on SocketException {
      throw InternetException('No Internet');
    } on TimeoutException {
      throw RequestTimeOut('Request timed out');
    }
  }

  Future<String> uploadAnyFile({
    // e.g. https://api.example.com
    String? filePath, // use on mobile/desktop
    Uint8List? bytes, // use on web / when you already have bytes
    String? fileName, // required if using bytes
    Map<String, String>? headers, // e.g. Authorization
    Map<String, String>? extraFields, // optional extra form fields
    String fileFieldName = 'file', // server expects 'file'
    String keyFieldName = 'key', // server expects 'key' (filename)
  }) async {
    if ((filePath == null || filePath.isEmpty) && (bytes == null)) {
      throw ArgumentError('Provide either filePath or bytes.');
    }
    if (bytes != null && (fileName == null || fileName.isEmpty)) {
      throw ArgumentError('fileName is required when uploading bytes.');
    }

    final uri = Uri.parse(AppUrl.uploadMedia());
    final request = http.MultipartRequest('POST', uri);

    // Add custom headers (do NOT set multipart Content-Type manually)
    if (headers != null) request.headers.addAll(headers);

    // Determine filename + mime
    final inferredName = filePath != null
        ? filePath.split('/').last
        : fileName!;
    final mime = lookupMimeType(inferredName) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mime);

    // Required fields for your endpoint
    request.fields[keyFieldName] = inferredName;

    // Optional extra fields (folder, ACL, userId, etc.)
    if (extraFields != null && extraFields.isNotEmpty) {
      request.fields.addAll(extraFields);
    }

    // Attach file
    if (filePath != null && filePath.isNotEmpty) {
      final part = await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
        filename: inferredName,
        contentType: mediaType,
      );
      request.files.add(part);
    } else {
      final part = http.MultipartFile.fromBytes(
        fileFieldName,
        bytes!,
        filename: inferredName,
        contentType: mediaType,
      );
      request.files.add(part);
    }

    // Send
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (kDebugMode) {
      print('📤 Upload → ${response.statusCode}');
      print('📤 Body → ${response.body}');
    }

    // Reuse your existing JSON handler
    final parsed = returnResponse(response);

    // Flexible extraction:
    // expect { "url": "..." } or { "data": { "url": "..." } }
    if (parsed is Map) {
      if (parsed['url'] is String) return parsed['url'] as String;
      final data = parsed['data'];
      if (data is Map && data['url'] is String) return data['url'] as String;
    }

    throw FetchDataException('Upload succeeded but URL missing in response');
  }

  Future<UploadResult> uploadVideoWithThumbnail({
    // Local files (mobile/desktop)
    String? videoPath,
    String? thumbnailPath,

    // Web (or memory) uploads
    Uint8List? videoBytes,
    Uint8List? thumbnailBytes,
    String? videoFileName,        // required when using bytes
    String? thumbnailFileName,    // required when using bytes

    String useCase = 'gigs-attachments',
    Map<String, String>? headers, // e.g., {'Authorization': 'Bearer ...'}
  }) async {
    // --- Validation ---
    final hasPaths = (videoPath?.isNotEmpty == true) && (thumbnailPath?.isNotEmpty == true);
    final hasBytes = (videoBytes != null && videoBytes.isNotEmpty) &&
                     (thumbnailBytes != null && thumbnailBytes.isNotEmpty) &&
                     (videoFileName?.isNotEmpty == true) &&
                     (thumbnailFileName?.isNotEmpty == true);

    if (!hasPaths && !hasBytes) {
      throw ArgumentError('Provide video+thumbnail via file paths OR via bytes+file names.');
    }

    // Your API expects mediaType=video
    final uri = Uri.parse('${AppUrl.uploadMedia()}?mediaType=video'); 
    final req = http.MultipartRequest('POST', uri);

    if (headers != null) req.headers.addAll(headers);
    req.fields['useCase'] = useCase;

    // Helper to guess content type
    MediaType _mt(String filename, {String fallback = 'application/octet-stream'}) {
      final mime = lookupMimeType(filename) ?? fallback;
      return MediaType.parse(mime);
    }

    if (hasPaths) {
      // Attach VIDEO
      final vName = videoPath!.split('/').last;
      req.files.add(
        await http.MultipartFile.fromPath(
          'file', // <-- MUST be 'file'
          videoPath,
          filename: vName,
          contentType: _mt(vName),
        ),
      );

      // Attach THUMBNAIL
      final tName = thumbnailPath!.split('/').last;
      req.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail', // <-- MUST be 'thumbnail'
          thumbnailPath,
          filename: tName,
          contentType: _mt(tName, fallback: 'image/png'),
        ),
      );
    } else {
      // BYTES path
      final vName = videoFileName!;
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          videoBytes!,
          filename: vName,
          contentType: _mt(vName),
        ),
      );

      final tName = thumbnailFileName!;
      req.files.add(
        http.MultipartFile.fromBytes(
          'thumbnail',
          thumbnailBytes!,
          filename: tName,
          contentType: _mt(tName, fallback: 'image/png'),
        ),
      );
    }

    if (kDebugMode) {
      print('📤 Sending single-call upload to: $uri');
      for (final f in req.files) {
        print('  • ${f.field} -> ${f.filename} (${f.contentType})');
      }
      print('  • useCase: $useCase');
    }

    final streamed = await req.send().timeout(const Duration(seconds: 180));
    final resp = await http.Response.fromStream(streamed);

    if (kDebugMode) {
      print('📤 Status: ${resp.statusCode}');
      print('📤 Body  : ${resp.body}');
    }

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Upload failed ${resp.statusCode}: ${resp.body}');
    }

    late final Map<String, dynamic> parsed;
    try {
      parsed = json.decode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON: ${resp.body}');
    }

    if (parsed['success'] != true) {
      throw Exception(parsed['message'] ?? 'Upload failed');
    }

    return UploadResult.fromJson(parsed);
  }

  dynamic returnResponse(http.Response response) {
    dynamic responseJson;

    try {
      responseJson = jsonDecode(response.body);
    } catch (e) {
      throw FetchDataException('Invalid response format from server');
    }

    final statusCode = response.statusCode;

    // ✅ Success
    if (statusCode >= 200 && statusCode < 300) {
      return responseJson;
    }
    // ❌ Client Error (400–499)
    else if (statusCode >= 400 && statusCode < 500) {
      // Extract the proper message from server if present
      final message = responseJson is Map && responseJson['message'] != null
          ? responseJson['message'].toString()
          : 'Request failed with status $statusCode';

      // Return a unified error map that controllers can directly read
      return {'error': true, 'statusCode': statusCode, 'message': message};
    }
    // 💥 Server Error (500–599)
    else if (statusCode >= 500 && statusCode < 600) {
      final message = responseJson is Map && responseJson['message'] != null
          ? responseJson['message'].toString()
          : 'Server error ($statusCode)';
      throw FetchDataException(message);
    }
    // ⚠️ Unexpected
    else {
      throw FetchDataException('Unexpected error: $statusCode');
    }
  }

  // dynamic returnResponse(http.Response response) {
  //   dynamic responseJson;

  //   try {
  //     responseJson = jsonDecode(response.body);
  //   } catch (e) {
  //     throw FetchDataException('Invalid response format from server');
  //   }

  //   if (response.statusCode >= 200 && response.statusCode < 300) {
  //     return responseJson;
  //   } else if (response.statusCode >= 400 && response.statusCode < 500) {
  //     return {'error': responseJson ?? 'Client Error: ${response.statusCode}'};
  //   } else if (response.statusCode >= 500 && response.statusCode < 600) {
  //     throw FetchDataException(
  //       responseJson['error'] ?? 'Server Error: ${response.statusCode}',
  //     );
  //   } else {
  //     throw FetchDataException('Unexpected error: ${response.statusCode}');
  //   }
  // }
}
