import 'package:flutter/foundation.dart';
import '../models/news.dart';
import '../services/api_service.dart';

class NewsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<News> _newsList = [];
  News? _selectedNews;
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;

  List<News> get newsList => _newsList;
  News? get selectedNews => _selectedNews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories => [
        'Semua',
        'Politik',
        'Ekonomi',
        'Teknologi',
        'Olahraga',
        'Entertainment',
        'Pendidikan',
        'Kesehatan'
      ];

  void setCategory(String? category) {
    _selectedCategory = category;
    fetchNews();
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = _selectedCategory == 'Semua' ? null : _selectedCategory;
      _newsList = await _apiService.getNews(category: category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load news: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewsDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedNews = await _apiService.getNewsDetail(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load news detail: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNews(
      String title, String content, String? category, String? image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createNews(title, content, category, image);

      if (result['success']) {
        await fetchNews();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to create news: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearSelectedNews() {
    _selectedNews = null;
    notifyListeners();
  }
}
