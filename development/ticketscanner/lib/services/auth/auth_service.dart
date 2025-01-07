import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String apiUrl =
      'https://your-api-url.com'; 
  final String clientId =
      'YOUR_CLIENT_ID'; 
  final String clientSecret =
      'YOUR_CLIENT_SECRET';
  final storage = const FlutterSecureStorage();

  // Login method for Laravel Passport
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$apiUrl/oauth/token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'grant_type': 'password',
          'client_id': clientId,
          'client_secret': clientSecret,
          'username': email,
          'password': password,
          'scope': '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save the access token securely
        await storage.write(key: 'access_token', value: data['access_token']);
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
        return {'success': true, 'data': data};
      } else {
        // Handle error responses
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      // Handle exceptions (network errors, etc.)
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Logout method
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  // Get the stored access token
  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }
}
