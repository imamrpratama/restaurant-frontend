import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/table.dart';
import '../services/api_service.dart';

class TableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TableModel> _tables = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch tables - FIXED
  Future<void> fetchTables() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/tables');

      // Check status code first
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode manually

        _tables =
            (data as List).map((json) => TableModel.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error fetching tables: $e');
    }
    _setLoading(false);
  }

  // Create table
  Future<bool> createTable(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _apiService.post('/tables', data);
      final newTable =
          TableModel.fromJson(_apiService.handleResponse(response));
      _tables.add(newTable);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Update table
  Future<bool> updateTable(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _apiService.put('/tables/$id', data);
      final updated = TableModel.fromJson(_apiService.handleResponse(response));

      final index = _tables.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tables[index] = updated;
      }

      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Delete table
  Future<bool> deleteTable(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/tables/$id');
      _tables.removeWhere((t) => t.id == id);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
