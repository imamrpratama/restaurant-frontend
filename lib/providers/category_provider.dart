import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/categories');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _categories =
            (data as List).map((json) => Category.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error fetching categories: $e');
    }
    _setLoading(false);
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _apiService.post('/categories', data);

      if (response.statusCode == 201) {
        final newCategory = Category.fromJson(jsonDecode(response.body));
        _categories.add(newCategory);
        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      print('Updating category $id with data: $data');

      final response = await _apiService.put('/categories/$id', data);

      print('Update category response status: ${response.statusCode}');
      print('Update category response body: ${response.body}');

      if (response.statusCode == 200) {
        final updated = Category.fromJson(jsonDecode(response.body));

        final index = _categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          _categories[index] = updated;
          print('Category updated in list at index $index');
        } else {
          print('Category not found in list, adding it');
          _categories.add(updated);
        }

        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      print('Error updating category: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _setLoading(true);
    try {
      final response = await _apiService.delete('/categories/$id');

      if (response.statusCode == 200) {
        _categories.removeWhere((c) => c.id == id);
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Cannot delete category');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
