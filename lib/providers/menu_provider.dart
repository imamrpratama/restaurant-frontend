import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/menu.dart';
import '../services/api_service.dart';

class MenuProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Menu> _menus = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Menu> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch menus
  Future<void> fetchMenus({int? categoryId}) async {
    _setLoading(true);
    try {
      final endpoint =
          categoryId != null ? '/menus?category_id=$categoryId' : '/menus';
      final response = await _apiService.get(endpoint);

      print('Fetch menus response status: ${response.statusCode}');
      print('Fetch menus response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _menus = (data as List).map((json) => Menu.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        throw Exception('Failed to load menus');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error fetching menus: $e');
    }
    _setLoading(false);
  }

  // Create menu
  Future<bool> createMenu(Map<String, String> data, File? imageFile) async {
    _setLoading(true);

    try {
      print('Creating menu with data: $data');

      final response = await _apiService.postMultipart(
        '/menus',
        data,
        imageFile,
        fileField: 'image',
      );

      print('Create menu response status: ${response.statusCode}');
      print('Create menu response body: ${response.body}');

      if (response.statusCode == 201) {
        final newMenu = Menu.fromJson(jsonDecode(response.body));
        _menus.add(newMenu);
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to create menu';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating menu: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update menu - FIXED
  Future<bool> updateMenu(
    int id,
    Map<String, String> data,
    File? imageFile,
  ) async {
    _setLoading(true);

    try {
      print('Updating menu $id with data: $data');
      print('Has new image: ${imageFile != null}');

      final response = await _apiService.putMultipart(
        '/menus/$id',
        data,
        imageFile,
        fileField: 'image',
      );

      print('Update menu response status: ${response.statusCode}');
      print('Update menu response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedMenu = Menu.fromJson(jsonDecode(response.body));

        final index = _menus.indexWhere((m) => m.id == id);
        if (index != -1) {
          _menus[index] = updatedMenu;
          print('Menu updated in list at index $index');
        } else {
          print('Menu not found in list, adding it');
          _menus.add(updatedMenu);
        }

        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to update menu';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error updating menu: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete menu
  Future<bool> deleteMenu(int id) async {
    _setLoading(true);
    try {
      final response = await _apiService.delete('/menus/$id');

      print('Delete menu response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        _menus.removeWhere((m) => m.id == id);
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete menu');
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
