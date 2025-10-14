import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lecture_model.dart';
import '../models/category_model.dart'; // IMPORT FROM SEPARATE FILE

class LectureProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<LectureModel> _lectures = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;

  List<LectureModel> get lectures => _lectures;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Statistics
  int get totalLectures => _lectures.length;
  int get totalDuration =>
      _lectures.fold(0, (sum, lecture) => sum + lecture.duration);
  int get favoriteCount =>
      _lectures.where((lecture) => lecture.isFavorite).length;

  // Untuk testing - hapus ketika backend sudah ready
  void addMockData() {
    _categories = [
      CategoryModel(
        categoryId: '1',
        userId: '1',
        name: 'Matematika',
        color: '#4CAF50',
        icon: '➕',
        description: 'Kategori untuk mata kuliah matematika',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        lecturesCount: 3,
      ),
      CategoryModel(
        categoryId: '2',
        userId: '1',
        name: 'Pemrograman',
        color: '#2196F3',
        icon: '💻',
        description: 'Kategori untuk mata kuliah pemrograman',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        lecturesCount: 5,
      ),
      CategoryModel(
        categoryId: '3',
        userId: '1',
        name: 'Fisika',
        color: '#FF9800',
        icon: '⚛️',
        description: 'Kategori untuk mata kuliah fisika',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        lecturesCount: 2,
      ),
    ];

    _lectures = [
      LectureModel(
        lectureId: '1',
        userId: '1',
        categoryId: '1',
        title: 'Kalkulus Dasar - Limit dan Turunan',
        description: 'Pengenalan konsep limit dan turunan dalam kalkulus',
        audioUrl: 'https://example.com/audio1.mp3',
        audioFormat: 'mp3',
        fileSize: 15728640, // 15 MB
        duration: 5400, // 1.5 jam
        recordingDate: DateTime.now().subtract(const Duration(days: 2)),
        recordingQuality: 'high',
        status: 'completed',
        processingProgress: 100,
        isFavorite: true,
        playCount: 8,
        playbackPosition: 1200,
        lastPlayedAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: _categories[0],
      ),
      LectureModel(
        lectureId: '2',
        userId: '1',
        categoryId: '2',
        title: 'Flutter State Management dengan Provider',
        description:
            'Memahami state management dalam Flutter menggunakan Provider',
        audioUrl: 'https://example.com/audio2.mp3',
        audioFormat: 'mp3',
        fileSize: 20971520, // 20 MB
        duration: 7200, // 2 jam
        recordingDate: DateTime.now().subtract(const Duration(days: 1)),
        recordingQuality: 'high',
        status: 'processing',
        processingProgress: 75,
        isFavorite: false,
        playCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        category: _categories[1],
      ),
      LectureModel(
        lectureId: '3',
        userId: '1',
        categoryId: '3',
        title: 'Mekanika Klasik - Hukum Newton',
        description: 'Pembahasan mendalam tentang hukum Newton dalam mekanika',
        audioUrl: 'https://example.com/audio3.mp3',
        audioFormat: 'mp3',
        fileSize: 10485760, // 10 MB
        duration: 3600, // 1 jam
        recordingDate: DateTime.now().subtract(const Duration(days: 3)),
        recordingQuality: 'standard',
        status: 'completed',
        processingProgress: 100,
        isFavorite: true,
        playCount: 12,
        playbackPosition: 1800,
        lastPlayedAt: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        category: _categories[2],
      ),
    ];

    notifyListeners();
  }

  Future<void> loadLectures({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _lectures.clear();
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/lectures',
        requiresAuth: true,
        queryParams: {'page': _currentPage.toString()},
      );

      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> lecturesData = [];

        // Handle different response structures
        if (data is Map && data.containsKey('data')) {
          lecturesData = data['data'] ?? [];
        } else if (data is List) {
          lecturesData = data;
        } else {
          lecturesData = [];
        }

        final List<LectureModel> loadedLectures = [];

        for (var item in lecturesData) {
          try {
            loadedLectures.add(LectureModel.fromJson(item));
          } catch (e) {
            print('Error parsing lecture: $e');
          }
        }

        if (refresh) {
          _lectures = loadedLectures;
        } else {
          _lectures.addAll(loadedLectures);
        }

        // Check if there are more pages
        if (data is Map && data['current_page'] != null) {
          _currentPage = (data['current_page'] as int) + 1;
          _hasMore = data['current_page'] < data['last_page'];
        } else {
          _hasMore = loadedLectures.length >= 20;
        }
      } else {
        _errorMessage = response['message'] ?? 'Failed to load lectures';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      print('LectureProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/categories', requiresAuth: true);

      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _categories = data
              .map<CategoryModel>((item) => CategoryModel.fromJson(item))
              .toList();
        }
      } else {
        _errorMessage = response['message'] ?? 'Failed to load categories';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      print('Categories error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String lectureId) async {
    try {
      final response = await _apiService.post(
        '/lectures/$lectureId/toggle-favorite',
        {},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final index = _lectures.indexWhere(
          (lecture) => lecture.lectureId == lectureId,
        );
        if (index != -1) {
          // Create updated lecture
          final updatedLecture = LectureModel.fromJson({
            ..._lectures[index].toJson(),
            'is_favorite':
                response['data']['is_favorite'] ?? !_lectures[index].isFavorite,
          });
          _lectures[index] = updatedLecture;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Toggle favorite error: $e');
    }
  }

  Future<void> deleteLecture(String lectureId) async {
    try {
      final response = await _apiService.delete(
        '/lectures/$lectureId',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        _lectures.removeWhere((lecture) => lecture.lectureId == lectureId);
        notifyListeners();
      }
    } catch (e) {
      print('Delete lecture error: $e');
    }
  }

  Future<void> createCategory({
    required String name,
    String? color,
    String? icon,
    String? description,
  }) async {
    try {
      final response = await _apiService.post('/categories', {
        'name': name,
        'color': color,
        'icon': icon,
        'description': description,
      }, requiresAuth: true);

      if (response['success'] == true) {
        final newCategory = CategoryModel.fromJson(response['data']);
        _categories.add(newCategory);
        notifyListeners();
      }
    } catch (e) {
      print('Create category error: $e');
    }
  }

  // Filter lectures by category
  List<LectureModel> getLecturesByCategory(String? categoryId) {
    if (categoryId == null) return _lectures;
    return _lectures
        .where((lecture) => lecture.categoryId == categoryId)
        .toList();
  }

  // Get favorite lectures
  List<LectureModel> get favoriteLectures {
    return _lectures.where((lecture) => lecture.isFavorite).toList();
  }

  // Get recent lectures (last 7 days)
  List<LectureModel> get recentLectures {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _lectures
        .where((lecture) => lecture.createdAt.isAfter(weekAgo))
        .toList();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Initialize data
  Future<void> initialize() async {
    // Untuk testing - hapus ketika backend sudah ready
    addMockData();

    // Uncomment ketika backend ready
    // await loadLectures(refresh: true);
    // await loadCategories();
  }
}
