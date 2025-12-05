import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  List<Order> _kitchenOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  List<Order> get kitchenOrders => _kitchenOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all orders
  Future<void> fetchOrders({String? status, int? tableId}) async {
    _setLoading(true);
    try {
      String endpoint = '/orders';
      List<String> queryParams = [];

      if (status != null) {
        queryParams.add('status=$status');
      }
      if (tableId != null) {
        queryParams.add('table_id=$tableId');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?' + queryParams.join('&');
      }

      final response = await _apiService.get(endpoint);

      print('Fetch orders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _orders = (data as List).map((json) => Order.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error fetching orders: $e');
    }
    _setLoading(false);
  }

  // Fetch kitchen display orders
  Future<void> fetchKitchenOrders({String? search}) async {
    _setLoading(true);
    try {
      String endpoint = '/kitchen-display';

      if (search != null && search.isNotEmpty) {
        endpoint += '?search=$search';
      }

      final response = await _apiService.get(endpoint);

      print('Fetch kitchen orders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _kitchenOrders =
            (data as List).map((json) => Order.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        throw Exception('Failed to load kitchen orders');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Error fetching kitchen orders: $e');
    }
    _setLoading(false);
  }

  // Create order
  Future<bool> createOrder(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      print('Creating order with data: $data');

      final response = await _apiService.post('/orders', data);

      print('Create order response status: ${response.statusCode}');
      print('Create order response body: ${response.body}');

      if (response.statusCode == 201) {
        final newOrder = Order.fromJson(jsonDecode(response.body));
        _orders.insert(0, newOrder);
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to create order';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update order status - FIXED
  Future<bool> updateOrderStatus(int orderId, String status) async {
    _setLoading(true);
    try {
      print('Updating order $orderId status to: $status');

      // Use PATCH method for status update
      final response = await _apiService.patch(
        '/orders/$orderId/status',
        {'status': status},
      );

      print('Update order status response status: ${response.statusCode}');
      print('Update order status response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedOrder = Order.fromJson(data['order']);

        // Update in orders list
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = updatedOrder;
        }

        // Update in kitchen orders list
        final kitchenIndex = _kitchenOrders.indexWhere((o) => o.id == orderId);
        if (kitchenIndex != -1) {
          if (status == 'done' || status == 'cancelled') {
            // Remove from kitchen display if done or cancelled
            _kitchenOrders.removeAt(kitchenIndex);
          } else {
            _kitchenOrders[kitchenIndex] = updatedOrder;
          }
        }

        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to update order status';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error updating order status: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete order
  Future<bool> deleteOrder(int orderId) async {
    _setLoading(true);
    try {
      final response = await _apiService.delete('/orders/$orderId');

      if (response.statusCode == 200) {
        _orders.removeWhere((o) => o.id == orderId);
        _kitchenOrders.removeWhere((o) => o.id == orderId);
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete order');
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
