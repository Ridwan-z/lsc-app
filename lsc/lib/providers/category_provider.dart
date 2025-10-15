import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🔹 Load all categories (GET)
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/categories',
        requiresAuth: true, // ✅ Tambahkan header Authorization
      );

      if (response['success'] == true && response['data'] != null) {
        _categories = (response['data'] as List)
            .map((item) => CategoryModel.fromJson(item))
            .toList();
        _error = null;
      } else {
        _categories = [];
        _error = response['message'] ?? 'Failed to load categories';
      }
    } catch (e) {
      _error = e.toString();
      _categories = [];
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Create new category (POST)
  Future<void> createCategory({
    required String name,
    required Color color,
  }) async {
    try {
      String colorHex =
          '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final response = await _apiService.post(
        '/categories',
        {'name': name, 'color': colorHex},
        requiresAuth: true, // ✅ Tambahkan header Authorization
      );

      if (response['success'] == true && response['data'] != null) {
        final newCategory = CategoryModel.fromJson(response['data']);
        _categories.add(newCategory);
        _categories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating category: $e');
      }
      rethrow;
    }
  }

  // 🔹 Update category (PUT)
  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required Color color,
  }) async {
    try {
      String colorHex =
          '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final response = await _apiService.put(
        '/categories/$categoryId',
        {'name': name, 'color': colorHex},
        requiresAuth: true, // ✅ Tambahkan header Authorization
      );

      if (response['success'] == true && response['data'] != null) {
        final updatedCategory = CategoryModel.fromJson(response['data']);
        final index = _categories.indexWhere((c) => c.categoryId == categoryId);
        if (index != -1) {
          _categories[index] = updatedCategory;
          _categories.sort((a, b) => a.name.compareTo(b.name));
          notifyListeners();
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating category: $e');
      }
      rethrow;
    }
  }

  // 🔹 Delete category (DELETE)
  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await _apiService.delete(
        '/categories/$categoryId',
        requiresAuth: true, // ✅ Tambahkan header Authorization
      );

      if (response['success'] == true) {
        _categories.removeWhere((c) => c.categoryId == categoryId);
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting category: $e');
      }
      rethrow;
    }
  }

  // 🔹 Get category by ID
  CategoryModel? getCategoryById(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return null;
    try {
      return _categories.firstWhere((c) => c.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }
}
