import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/news.dart';
import '../models/comment.dart';

class ApiService {
  // Auto detect platform and use appropriate URL
  // Web: http://127.0.0.1:8000/api
  // Android Emulator: http://10.0.2.2:8000/api
  // Physical Device: http://YOUR_IP:8000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> _headers({bool includeAuth = false, String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Auth APIs
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers(),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _headers(includeAuth: true, token: token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<User?> getUser() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: _headers(includeAuth: true, token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // News APIs
  Future<List<News>> getNews({String? category, int page = 1}) async {
    try {
      String url = '$baseUrl/news?page=$page';
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List newsData = data['data']['data'];
        return newsData.map((json) => News.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  Future<News?> getNewsDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/$id'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return News.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching news detail: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> createNews(
      String title, String content, String? category, String? image) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/news'),
        headers: _headers(includeAuth: true, token: token),
        body: json.encode({
          'title': title,
          'content': content,
          'category': category,
          'image': image,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Comment APIs
  Future<List<Comment>> getComments(int newsId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/$newsId/comments'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List commentsData = data['data'];
        return commentsData.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addComment(int newsId, String content) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/news/$newsId/comments'),
        headers: _headers(includeAuth: true, token: token),
        body: json.encode({
          'content': content,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteComment(int commentId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: _headers(includeAuth: true, token: token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
