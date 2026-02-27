import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:collaby_app/res/app_url/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ChatRepository {
  final String baseUrl = AppUrl.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Verify token and get user data
  Future<Map<String, dynamic>> verifyToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Token verification failed: ${response.body}');
    }
  }

  // Get user chats
  Future<List<dynamic>> getUserChats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/user/$userId'),
      headers: _headers,
    );

    log('getUserChats response: ${json.decode(response.body)}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle both array and wrapped response
      return data is List ? data : (data['data'] ?? data['chats'] ?? []);
    } else {
      throw Exception('Failed to load chats');
    }
  }

  // Get chat messages
  Future<List<dynamic>> getOrderChatMessages(
    String chatId,
    String orderId,
  ) async {
    try {
      // Remove page and limit parameters - backend doesn't support them
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId/messages?orderId=$orderId'),
        headers: _headers,
      );

      log('Get messages response status: ${response.statusCode}');
      log('Get messages response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        if (data is List) {
          return data;
        } else if (data is Map) {
          if (data.containsKey('data')) {
            final messagesData = data['data'];
            if (messagesData is List) {
              return messagesData;
            } else if (messagesData is Map &&
                messagesData.containsKey('messages')) {
              return messagesData['messages'] as List? ?? [];
            }
          } else if (data.containsKey('messages')) {
            return data['messages'] as List? ?? [];
          }
        }

        log('Unexpected response format: $data');
        return [];
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      log('Error in getChatMessages: $e');
      throw Exception('Failed to load messages');
    }
  }

  // Get chat messages
  Future<List<dynamic>> getChatMessages(String chatId) async {
    try {
      // Remove page and limit parameters - backend doesn't support them
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId/messages'),
        headers: _headers,
      );

      log('Get messages response status: ${response.statusCode}');
      log('Get messages response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        if (data is List) {
          return data;
        } else if (data is Map) {
          if (data.containsKey('data')) {
            final messagesData = data['data'];
            if (messagesData is List) {
              return messagesData;
            } else if (messagesData is Map &&
                messagesData.containsKey('messages')) {
              return messagesData['messages'] as List? ?? [];
            }
          } else if (data.containsKey('messages')) {
            return data['messages'] as List? ?? [];
          }
        }

        log('Unexpected response format: $data');
        return [];
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      log('Error in getChatMessages: $e');
      throw Exception('Failed to load messages');
    }
  }

  // Create new chat
  Future<Map<String, dynamic>> createChat(String targetUserId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
      body: json.encode({'targetUserId': targetUserId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Failed to create chat: ${response.body}');
    }
  }

  // Search users
  Future<List<dynamic>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/search?q=${Uri.encodeComponent(query)}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : (data['data'] ?? []);
    } else {
      throw Exception('Failed to search users: ${response.body}');
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/chat/$chatId/read'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark chat as read: ${response.body}');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/chat/messages/$messageId/read'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as read: ${response.body}');
    }
  }

  // Upload media
  Future<Map<String, dynamic>> uploadMedia(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/s3/upload-media'),
      );

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Determine file type
      String mimeType = _getMimeType(file.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to upload media: ${response.body}');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Custom Offer APIs
  Future<Map<String, dynamic>> createCustomOffer(
    Map<String, dynamic> offerData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/custom-offers'),
      headers: _headers,
      body: json.encode(offerData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create custom offer: ${response.body}');
    }
  }

  // Future<Map<String, dynamic>> createCustomOffer(
  //   Map<String, dynamic> offerData,
  // ) async {
  //   try {
  //     // Make the API request
  //     final response = await http.post(
  //       Uri.parse('$BASE_URL/custom-offers'),
  //       headers: _headers,
  //       body: json.encode(offerData),
  //     );

  //     // Check if the response status is 200 (success) or 201 (created)
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return json.decode(response.body); // Return the response data as a map
  //     } else {
  //       // If the request was not successful, show an error message
  //       throw Exception('Failed to create custom offer: ${response.body}');
  //     }
  //   } catch (e) {
  //     // Catch any errors or exceptions
  //     Utils.snackBar(
  //       'Error', // Title for the Snackbar
  //       'Failed to create custom offer: ${e.toString()}', // Message with the error
  //       // White text color
  //     );
  //     rethrow; // Re-throw the error to propagate it further if needed
  //   }
  // }

  Future<Map<String, dynamic>> acceptCustomOffer(
    String offerId, {
    String message = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/custom-offers/$offerId/accept'),
      headers: _headers,
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to accept offer: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> declineCustomOffer(
    String offerId, {
    String reason = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/custom-offers/$offerId/decline'),
      headers: _headers,
      body: json.encode({'reason': reason}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to decline offer: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> withdrawCustomOffer(
    String offerId, {
    String? reason,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/custom-offers/$offerId/withdraw'),
      headers: _headers,
      body: json.encode({'reason': reason}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to withdraw offer: ${response.body}');
    }
  }

  Future<List<dynamic>> getUserGigs(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gig/creator/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : (data['data'] ?? data['gigs'] ?? []);
    } else {
      throw Exception('Failed to load gigs: ${response.body}');
    }
  }
}
