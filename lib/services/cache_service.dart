import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _ordersKey = 'cached_orders';
  static const String _kitchenDisplayKey = 'cached_kitchen_display';
  static const String _categoriesKey = 'cached_categories';
  static const String _menusKey = 'cached_menus';
  static const String _tablesKey = 'cached_tables';
  static const String _cacheTimestampKey = 'cache_timestamp_';

  // Cache duration in seconds
  static const int cacheDurationSeconds = 30;

  // Orders
  static Future<void> cacheOrders(List<dynamic> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ordersKey, jsonEncode(orders));
    await prefs.setInt(
        '${_cacheTimestampKey}orders', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<dynamic>?> getCachedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_ordersKey);
    if (cached == null) return null;

    final timestamp = prefs.getInt('${_cacheTimestampKey}orders') ?? 0;
    final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp >
        (cacheDurationSeconds * 1000);

    if (isExpired) {
      await prefs.remove(_ordersKey);
      return null;
    }

    return jsonDecode(cached);
  }

  // Kitchen Display
  static Future<void> cacheKitchenDisplay(List<dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kitchenDisplayKey, jsonEncode(items));
    await prefs.setInt(
        '${_cacheTimestampKey}kitchen', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<dynamic>?> getCachedKitchenDisplay() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kitchenDisplayKey);
    if (cached == null) return null;

    final timestamp = prefs.getInt('${_cacheTimestampKey}kitchen') ?? 0;
    final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp >
        (cacheDurationSeconds * 1000);

    if (isExpired) {
      await prefs.remove(_kitchenDisplayKey);
      return null;
    }

    return jsonDecode(cached);
  }

  // Categories
  static Future<void> cacheCategories(List<dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(items));
    await prefs.setInt('${_cacheTimestampKey}categories',
        DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<dynamic>?> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_categoriesKey);
    if (cached == null) return null;

    final timestamp = prefs.getInt('${_cacheTimestampKey}categories') ?? 0;
    final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp >
        (cacheDurationSeconds * 1000);

    if (isExpired) {
      await prefs.remove(_categoriesKey);
      return null;
    }

    return jsonDecode(cached);
  }

  // Menus
  static Future<void> cacheMenus(List<dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_menusKey, jsonEncode(items));
    await prefs.setInt(
        '${_cacheTimestampKey}menus', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<dynamic>?> getCachedMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_menusKey);
    if (cached == null) return null;

    final timestamp = prefs.getInt('${_cacheTimestampKey}menus') ?? 0;
    final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp >
        (cacheDurationSeconds * 1000);

    if (isExpired) {
      await prefs.remove(_menusKey);
      return null;
    }

    return jsonDecode(cached);
  }

  // Tables
  static Future<void> cacheTables(List<dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tablesKey, jsonEncode(items));
    await prefs.setInt(
        '${_cacheTimestampKey}tables', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<dynamic>?> getCachedTables() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_tablesKey);
    if (cached == null) return null;

    final timestamp = prefs.getInt('${_cacheTimestampKey}tables') ?? 0;
    final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp >
        (cacheDurationSeconds * 1000);

    if (isExpired) {
      await prefs.remove(_tablesKey);
      return null;
    }

    return jsonDecode(cached);
  }

  // Clear all cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
    await prefs.remove(_kitchenDisplayKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_menusKey);
    await prefs.remove(_tablesKey);
    await prefs.remove('${_cacheTimestampKey}orders');
    await prefs.remove('${_cacheTimestampKey}kitchen');
    await prefs.remove('${_cacheTimestampKey}categories');
    await prefs.remove('${_cacheTimestampKey}menus');
    await prefs.remove('${_cacheTimestampKey}tables');
  }

  // Clear specific cache
  static Future<void> clearOrdersCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
    await prefs.remove('${_cacheTimestampKey}orders');
  }

  static Future<void> clearKitchenCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kitchenDisplayKey);
    await prefs.remove('${_cacheTimestampKey}kitchen');
  }
}
